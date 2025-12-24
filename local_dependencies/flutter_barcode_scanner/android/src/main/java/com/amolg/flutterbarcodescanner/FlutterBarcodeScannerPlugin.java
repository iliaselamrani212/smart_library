package com.amolg.flutterbarcodescanner;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.vision.barcode.Barcode;

import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;


/**
 * FlutterBarcodeScannerPlugin
 */
public class FlutterBarcodeScannerPlugin implements MethodCallHandler, ActivityResultListener, StreamHandler, FlutterPlugin, ActivityAware {
    private static final String CHANNEL = "flutter_barcode_scanner";

    private static FlutterActivity activity;
    private static Result pendingResult;
    private Map<String, Object> arguments;

    private static final String TAG = FlutterBarcodeScannerPlugin.class.getSimpleName();
    private static final int RC_BARCODE_CAPTURE = 9001;
    public static String lineColor = "";
    public static boolean isShowFlashIcon = false;
    public static boolean isContinuousScan = false;
    static EventChannel.EventSink barcodeStream;
    private EventChannel eventChannel;

    /**
     * V2 embedding
     */
    private MethodChannel channel;
    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;
    private Application applicationContext;
    // This is null when not using v2 embedding;
    private Lifecycle lifecycle;
    private LifeCycleObserver observer;

    public FlutterBarcodeScannerPlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        pluginBinding = flutterPluginBinding;
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_barcode_scanner");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            pendingResult = result;

            if (call.method.equals("scanBarcode")) {
                if (!(call.arguments instanceof Map)) {
                    throw new IllegalArgumentException("Plugin not passing a map as parameter: " + call.arguments);
                }
                arguments = (Map<String, Object>) call.arguments;
                lineColor = (String) arguments.get("lineColor");
                isShowFlashIcon = (boolean) arguments.get("isShowFlashIcon");
                if (null == lineColor || lineColor.equalsIgnoreCase("")) {
                    lineColor = "#DC143C";
                }
                if (null != arguments.get("scanMode")) {
                    if ((int) arguments.get("scanMode") == BarcodeCaptureActivity.SCAN_MODE_ENUM.DEFAULT.ordinal()) {
                        BarcodeCaptureActivity.SCAN_MODE = BarcodeCaptureActivity.SCAN_MODE_ENUM.QR.ordinal();
                    } else {
                        BarcodeCaptureActivity.SCAN_MODE = (int) arguments.get("scanMode");
                    }
                } else {
                    BarcodeCaptureActivity.SCAN_MODE = BarcodeCaptureActivity.SCAN_MODE_ENUM.QR.ordinal();
                }

                isContinuousScan = (boolean) arguments.get("isContinuousScan");

                startBarcodeScannerActivityView((String) arguments.get("cancelButtonText"), isContinuousScan);
            } else {
                result.notImplemented();
            }
        } catch (Exception e) {
            result.error("ERROR", e.getMessage(), null);
        }
    }

    private void startBarcodeScannerActivityView(String buttonText, boolean isContinuousScan) {
        try {
            Intent intent = new Intent(activity, BarcodeCaptureActivity.class).putExtra("cancelButtonText", buttonText);
            if (isContinuousScan) {
                activity.startActivity(intent);
            } else {
                activity.startActivityForResult(intent, RC_BARCODE_CAPTURE);
            }
        } catch (Exception e) {
            Log.e(TAG, "startView: " + e.getLocalizedMessage());
        }
    }


    /**
     * Get the barcode scanning results in onActivityResult
     *
     * @param requestCode
     * @param resultCode
     * @param data
     * @return
     */
    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == RC_BARCODE_CAPTURE) {
            if (resultCode == CommonStatusCodes.SUCCESS) {
                if (data != null) {
                    try {
                        Barcode barcode = data.getParcelableExtra(BarcodeCaptureActivity.BarcodeObject);
                        String barcodeResult = barcode.rawValue;
                        pendingResult.success(barcodeResult);
                    } catch (Exception e) {
                        pendingResult.success("-1");
                    }
                } else {
                    pendingResult.success("-1");
                }
                pendingResult = null;
                arguments = null;
                return true;
            } else {
                pendingResult.success("-1");
            }
        }
        return false;
    }


    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        try {
            barcodeStream = eventSink;
        } catch (Exception e) {
        }
    }

    @Override
    public void onCancel(Object o) {
        try {
            barcodeStream = null;
        } catch (Exception e) {

        }
    }

    /**
     * Continuous receive barcode
     *
     * @param barcode
     */
    public static void onBarcodeScanReceiver(final Barcode barcode) {
        try {
            if (barcode != null && !barcode.displayValue.isEmpty()) {
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        barcodeStream.success(barcode.rawValue);
                    }
                });
            }
        } catch (Exception e) {
            Log.e(TAG, "onBarcodeScanReceiver: " + e.getLocalizedMessage());
        }
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        activityBinding = binding;
        createPluginSetup(
                pluginBinding.getBinaryMessenger(),
                (Application) pluginBinding.getApplicationContext(),
                activityBinding.getActivity(),
                null,
                activityBinding);
    }

    @Override
    public void onDetachedFromActivity() {
        clearPluginSetup();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        // Reattach the activity binding and reinitialize the plugin setup
        activityBinding = binding;
        createPluginSetup(
                pluginBinding.getBinaryMessenger(),
                (Application) pluginBinding.getApplicationContext(),
                activityBinding.getActivity(),
                null,
                activityBinding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        // Clear the plugin setup when the activity is detached for configuration changes
        clearPluginSetup();
    }

    /**
     * Clear plugin setup
     */
    private void clearPluginSetup() {
        activity = null;
        activityBinding.removeActivityResultListener(this);
        activityBinding = null;
        lifecycle.removeObserver(observer);
        lifecycle = null;
        channel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
        channel = null;
        applicationContext.unregisterActivityLifecycleCallbacks(observer);
        applicationContext = null;
    }

    /**
     * Create plugin setup
     */
    private void createPluginSetup(BinaryMessenger messenger, Application application, Activity activity, Object lifecycle, ActivityPluginBinding binding) {
        this.activity = (FlutterActivity) activity;
        this.applicationContext = application;
        this.activityBinding = binding;

        // Set up the method channel
        channel = new MethodChannel(messenger, CHANNEL);
        channel.setMethodCallHandler(this);

        // Set up the event channel
        eventChannel = new EventChannel(messenger, CHANNEL + "/events");
        eventChannel.setStreamHandler(this);

        // Add activity result listener
        if (binding != null) {
            binding.addActivityResultListener(this);
        }

        // Set up lifecycle observer if lifecycle is provided
        if (lifecycle instanceof Lifecycle) {
            this.lifecycle = (Lifecycle) lifecycle;
            observer = new LifeCycleObserver(activity);
            this.lifecycle.addObserver(observer);
        } else {
            Log.w(TAG, "Lifecycle is null or not an instance of Lifecycle. Skipping lifecycle observer setup.");
        }

        // Register activity lifecycle callbacks
        if (application != null) {
            observer = new LifeCycleObserver(activity);
            application.registerActivityLifecycleCallbacks(observer);
        } else {
            Log.e(TAG, "Application context is null. Cannot register lifecycle callbacks.");
        }
    }

    /**
     * Activity lifecycle observer
     */
    private class LifeCycleObserver
            implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {
        private final Activity thisActivity;

        LifeCycleObserver(Activity activity) {
            this.thisActivity = activity;
        }

        @Override
        public void onCreate(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onStart(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onResume(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onPause(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onStop(@NonNull LifecycleOwner owner) {
            onActivityStopped(thisActivity);
        }

        @Override
        public void onDestroy(@NonNull LifecycleOwner owner) {
            onActivityDestroyed(thisActivity);
        }

        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        }

        @Override
        public void onActivityStarted(Activity activity) {
        }

        @Override
        public void onActivityResumed(Activity activity) {
        }

        @Override
        public void onActivityPaused(Activity activity) {
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            if (thisActivity == activity && activity.getApplicationContext() != null) {
                ((Application) activity.getApplicationContext())
                        .unregisterActivityLifecycleCallbacks(
                                this);
            }
        }

        @Override
        public void onActivityStopped(Activity activity) {

        }
    }
}