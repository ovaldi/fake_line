package io.github.v7lin.fakeline;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ProviderInfo;
import android.net.Uri;
import android.os.Build;
import android.text.TextUtils;

import androidx.core.content.FileProvider;

import java.io.File;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.github.v7lin.fakeline.content.FakeLineFileProvider;

/**
 * FakeLinePlugin
 */
public class FakeLinePlugin implements MethodCallHandler {
    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "v7lin.github.io/fake_line");
        FakeLinePlugin plugin = new FakeLinePlugin(registrar);
        channel.setMethodCallHandler(plugin);
    }

    private static final String LINE_PACKAGE_NAME = "jp.naver.line.android";

    private static final String METHOD_ISLINEINSTALLED = "isLineInstalled";
    private static final String METHOD_SHARETEXT = "shareText";
    private static final String METHOD_SHAREIMAGE = "shareImage";

    private static final String ARGUMENT_KEY_TEXT = "text";
    private static final String ARGUMENT_KEY_IMAGEURI = "imageUri";

    private final Registrar registrar;

    public FakeLinePlugin(Registrar registrar) {
        this.registrar = registrar;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (TextUtils.equals(METHOD_ISLINEINSTALLED, call.method)) {
            result.success(isAppInstalled(registrar.context(), LINE_PACKAGE_NAME));
        } else if (TextUtils.equals(METHOD_SHARETEXT, call.method)) {
            shareText(call, result);
        } else if (TextUtils.equals(METHOD_SHAREIMAGE, call.method)) {
            shareImage(call, result);
        } else {
            result.notImplemented();
        }
    }

    private void shareText(MethodCall call, Result result) {
        String text = call.argument(ARGUMENT_KEY_TEXT);
        Intent shareIntent = new Intent();
        shareIntent.setData(Uri.parse("line://msg/text?")
                .buildUpon()
                .appendPath(text)
                .build());
        shareIntent.setPackage(LINE_PACKAGE_NAME);
        if (shareIntent.resolveActivity(registrar.context().getPackageManager()) != null) {
            registrar.activity().startActivity(shareIntent);
        }
        result.success(null);
    }

    private void shareImage(MethodCall call, Result result) {
        String imageUri = call.argument(ARGUMENT_KEY_IMAGEURI);
        Uri imageUrl = Uri.parse(imageUri);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            try {
                ProviderInfo providerInfo = registrar.context().getPackageManager().getProviderInfo(new ComponentName(registrar.context(), FakeLineFileProvider.class), PackageManager.MATCH_DEFAULT_ONLY);
                imageUrl = FileProvider.getUriForFile(registrar.context(), providerInfo.authority, new File(imageUrl.getPath()));
            } catch (PackageManager.NameNotFoundException e) {
            }
        }
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra(Intent.EXTRA_STREAM, imageUrl);
        sendIntent.setType("image/*");
        sendIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        sendIntent.setPackage(LINE_PACKAGE_NAME);
        if (sendIntent.resolveActivity(registrar.context().getPackageManager()) != null) {
            registrar.activity().startActivity(sendIntent);
        }
        result.success(null);
    }

    // ---

    private boolean isAppInstalled(Context context, String packageName) {
        PackageInfo packageInfo = null;
        try {
            packageInfo = context.getPackageManager().getPackageInfo(packageName, 0);
        } catch (PackageManager.NameNotFoundException e) {
        }
        return packageInfo != null;
    }
}
