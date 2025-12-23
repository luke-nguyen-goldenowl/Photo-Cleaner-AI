package com.felix.aiPhotoCleaner

import io.flutter.embedding.android.FlutterActivity
import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.widget.Toast
import androidx.media3.common.MediaItem
import androidx.media3.common.util.UnstableApi
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.EditedMediaItemSequence
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.ProgressHolder
import androidx.media3.transformer.Transformer
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException

@UnstableApi
class MainActivity : FlutterActivity(), Transformer.Listener{
    private var fileName: String? = null
    private var filePath: File? = null

    private val handler = Handler(Looper.getMainLooper())
    private val progressHolder = ProgressHolder()

    private val eventChannel = "progress"
    private var attachEvent: EventChannel.EventSink? = null

    private lateinit var methodChannel: MethodChannel.Result

    private val editedMediaItemList = mutableListOf<EditedMediaItem>()
    private val audioEditedMediaItemList = mutableListOf<EditedMediaItem>()


    override fun configureFlutterEngine(flutterEngine: FlutterEngine){
        super.configureFlutterEngine(flutterEngine)        
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            eventChannel
        ).setStreamHandler(
            object: EventChannel.StreamHandler{
                override fun onListen(args: Any?, events: EventChannel.EventSink){
                    attachEvent = events
                }

                override fun onCancel(args: Any?){
                    attachEvent = null
                }
            }
        )
        
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "videoPickerPlatform"
        ).setMethodCallHandler{call, result ->
            methodChannel = result
            when(call.method){
                "pickImage" -> {
                    val imageUrls = call.argument<List<String>>("path")
                    val audioUrl = call.argument<String>("audio")

                    val transformer = with(Transformer.Builder(context)){
                        addListener(this@MainActivity)
                        build()
                    }

                    if(!imageUrls.isNullOrEmpty() && audioUrl!= null){
                        // Clear previous items
                        editedMediaItemList.clear()
                        audioEditedMediaItemList.clear()
                        
                        for(url in imageUrls){
                            // Create MediaItem with image duration
                            val mediaItem = MediaItem.Builder()
                                .setUri(url)
                                .setImageDurationMs(3000) // 3 seconds per image
                                .build()
                            
                            editedMediaItemList.add(
                                EditedMediaItem.Builder(mediaItem)
                                    .setFrameRate(30)
                                    .build()
                            )
                        }

                        audioEditedMediaItemList.add(
                            EditedMediaItem.Builder(
                                MediaItem.fromUri(audioUrl)
                            ).build()
                        )

                        val mediaItemSequence = EditedMediaItemSequence.Builder(editedMediaItemList)
                            .build()

                        val backgroundAudioSequence = EditedMediaItemSequence.Builder(
                            audioEditedMediaItemList
                        )
                            .setIsLooping(true)
                            .build()

                        val composition = Composition.Builder(mediaItemSequence, backgroundAudioSequence)
                            .build()

                        filePath = createExternalFile()
                        
                        if (filePath != null) {
                            transformer.start(composition, filePath?.absolutePath!!)

                            handler.post(
                                object : Runnable{
                                    override fun run(){
                                        val progressState: @Transformer.ProgressState Int =
                                            transformer.getProgress(progressHolder)
                                        attachEvent?.success("$progressState ${progressHolder.progress}")

                                        if(progressState != Transformer.PROGRESS_STATE_NOT_STARTED){
                                            handler.postDelayed(this, 500)
                                        }
                                    }
                                }
                            )
                        } else {
                            methodChannel.error("FILE_ERROR", "Could not create output file", null)
                        }
                    } else {
                        methodChannel.error("INVALID_ARGS", "Images or audio URL is missing", null)
                    }
                }
                "saveVideo" -> {
                    val videoPath = call.argument<String>("path")
                    if (videoPath != null) {
                        val videoFile = File(videoPath)
                        if (videoFile.exists()) {
                            val displayName = "${System.currentTimeMillis()}MemoryVideo"
                            CoroutineScope(Dispatchers.Main).launch {
                                try {
                                    val uri = addVideoToGallery(videoFile, displayName)
                                    if (uri != null) {
                                        methodChannel.success(uri.toString())
                                        Toast.makeText(context, "Video saved to Gallery", Toast.LENGTH_SHORT).show()
                                    } else {
                                        methodChannel.error("SAVE_ERROR", "Failed to save video to Gallery", null)
                                        Toast.makeText(context, "Failed to save video", Toast.LENGTH_SHORT).show()
                                    }
                                } catch (e: Exception) {
                                    e.printStackTrace()
                                    methodChannel.error("SAVE_ERROR", "Error: ${e.message}", null)
                                    Toast.makeText(context, "Error saving video: ${e.message}", Toast.LENGTH_SHORT).show()
                                }
                            }
                        } else {
                            methodChannel.error("FILE_ERROR", "Video file not found", null)
                        }
                    } else {
                        methodChannel.error("INVALID_ARGS", "Video path is missing", null)
                    }
                }
            }
        }
    }

    private fun createExternalFile():File?{
        return try{
            fileName = "${System.currentTimeMillis()}MediaFileTrans.mp4"
            val file = File(context.externalCacheDir, "$fileName")
            check(!(file.exists() && !file.delete())) {"Could not delete the previous transformer output file"}
            check(file.createNewFile()) {"Could not create the transformer output file"}
            file
        } catch (e: IOException){
            Toast.makeText(
                context,
                "Could not create the transformer output file ${e.message}",
                Toast.LENGTH_SHORT
            ).show()
            null
        }
    }

    private suspend fun addVideoToGallery(file: File, displayName: String): Uri? = 
        withContext(Dispatchers.IO) {
            try {
                println("Starting to save video: ${file.absolutePath}, API Level: ${Build.VERSION.SDK_INT}")
                
                if (!file.exists()) {
                    println("ERROR: File does not exist!")
                    return@withContext null
                }
                
                println("File exists, size: ${file.length()} bytes")
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    // For Android 10+ (API 29+)
                    println("Using Android 10+ method")
                    val cv = ContentValues().apply {
                        put(MediaStore.Video.Media.DISPLAY_NAME, "$displayName.mp4")
                        put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
                        put(MediaStore.Video.Media.RELATIVE_PATH, Environment.DIRECTORY_DCIM)
                        put(MediaStore.Video.Media.DATE_ADDED, System.currentTimeMillis() / 1000)
                        put(MediaStore.Video.Media.DATE_TAKEN, System.currentTimeMillis())
                        put(MediaStore.Video.Media.IS_PENDING, 1)
                    }
                    
                    val resolver = context.contentResolver
                    val collection = MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
                    println("Collection URI: $collection")
                    
                    val uriSavedVideo = resolver.insert(collection, cv)
                    println("Insert result URI: $uriSavedVideo")
                    
                    if (uriSavedVideo != null) {
                        resolver.openOutputStream(uriSavedVideo)?.use { out ->
                            FileInputStream(file).use { inputStream ->
                                val buf = ByteArray(8192)
                                var len: Int
                                var totalBytes = 0L
                                while (inputStream.read(buf).also { len = it } > 0) {
                                    out.write(buf, 0, len)
                                    totalBytes += len
                                }
                                println("Copied $totalBytes bytes")
                            }
                        }
                        
                        cv.clear()
                        cv.put(MediaStore.Video.Media.IS_PENDING, 0)
                        resolver.update(uriSavedVideo, cv, null, null)
                        println("Video saved successfully to: $uriSavedVideo")
                    }
                    
                    return@withContext uriSavedVideo
                } else {
                    // For Android 9 and below (API 28 and below)
                    println("Using Android 9 and below method")
                    val videoDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM)
                    println("Video directory: ${videoDir.absolutePath}")
                    
                    if (!videoDir.exists()) {
                        val created = videoDir.mkdirs()
                        println("Directory created: $created")
                    }
                    
                    val destFile = File(videoDir, "$displayName.mp4")
                    println("Destination file: ${destFile.absolutePath}")
                    
                    // Copy file
                    FileInputStream(file).use { inputStream ->
                        FileOutputStream(destFile).use { out ->
                            val buf = ByteArray(8192)
                            var len: Int
                            var totalBytes = 0L
                            while (inputStream.read(buf).also { len = it } > 0) {
                                out.write(buf, 0, len)
                                totalBytes += len
                            }
                            println("Copied $totalBytes bytes to ${destFile.absolutePath}")
                        }
                    }
                    
                    // Add to MediaStore
                    val cv = ContentValues().apply {
                        put(MediaStore.Video.Media.TITLE, displayName)
                        put(MediaStore.Video.Media.DISPLAY_NAME, "$displayName.mp4")
                        put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
                        put(MediaStore.Video.Media.DATA, destFile.absolutePath)
                        put(MediaStore.Video.Media.DATE_ADDED, System.currentTimeMillis() / 1000)
                        put(MediaStore.Video.Media.DATE_TAKEN, System.currentTimeMillis())
                    }
                    
                    val resolver = context.contentResolver
                    val uri = resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, cv)
                    println("MediaStore insert result: $uri")
                    
                    return@withContext uri
                }
            } catch (e: Exception) {
                println("ERROR saving video: ${e.message}")
                e.printStackTrace()                
                return@withContext null
            }
        }

    override fun onCompleted(composition: Composition, exportResult: ExportResult) {
        super.onCompleted(composition, exportResult)

        // Return the file path without automatically saving to gallery
        if (filePath != null) {
            methodChannel.success(filePath?.absolutePath ?: "")
            Toast.makeText(context, "Video created successfully", Toast.LENGTH_SHORT).show()
        } else {
            methodChannel.error("SAVE_ERROR", "Failed to create video", null)
            Toast.makeText(context, "Failed to create video", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onError(
        composition: Composition,
        exportResult: ExportResult,
        exportException: ExportException
    ) {
        super.onError(composition, exportResult, exportException)
        println("Transformation Failed ${exportException.errorCodeName}")
        exportException.printStackTrace()

        Toast.makeText(
            context,
            "Transformation Failed ${exportException.errorCodeName}",
            Toast.LENGTH_SHORT
        ).show()
        
        methodChannel.error(
            "TRANSFORMATION_ERROR",
            "Transformation Failed: ${exportException.errorCodeName}",
            exportException.message
        )
    }
}
