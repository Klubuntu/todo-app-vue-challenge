{ pkgs ? import <nixpkgs> {} }:

let
  gst = pkgs.gst_all_1;
in

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    rustc
    cargo
    pkg-config
    clang
    lld
    cmake

    # GStreamer tools (gst-inspect-1.0, etc.)
    gst.gstreamer
  ];

  buildInputs = with pkgs; [
    # GTK / Tauri
    glib
    gtk3
    webkitgtk_4_1
    cairo
    pango
    gdk-pixbuf
    atk
    libsoup_3

    # GStreamer
    gst.gstreamer
    gst.gst-plugins-base
    gst.gst-plugins-good
    gst.gst-plugins-bad
    gst.gst-libav

    # Math libs
    blas
    lapack

    # Graphics
    libx11
    libGL
    mesa
    vulkan-loader # Dodane: Potrzebne dla nowoczesnego renderowania w Tauri v2
  ];

  shellHook = ''
    # Load environment variables if .env exists
    if [ -f .env ]; then
      export $(grep -v '^#' .env | xargs)
    fi

    if [ -n "$GIT_USER_EMAIL" ]; then
      git config user.email "$GIT_USER_EMAIL"
    fi

    # Set up a credential helper for the GITHUB_TOKEN if it exists
    if [ -n "$GITHUB_TOKEN" ]; then
      export GIT_ASKPASS=$(mktemp)
      cat <<EOF > $GIT_ASKPASS
#!/bin/sh
case "\$1" in
  Username*) echo "Klubuntu" ;;
  Password*) echo "\$GITHUB_TOKEN" ;;
esac
EOF
      chmod +x $GIT_ASKPASS
      # Clean up the temp file on exit
      trap "rm -f $GIT_ASKPASS" EXIT
    fi

    export GST_PLUGIN_SYSTEM_PATH_1_0="${gst.gst-plugins-base}/lib/gstreamer-1.0:${gst.gst-plugins-good}/lib/gstreamer-1.0:${gst.gst-plugins-bad}/lib/gstreamer-1.0:${gst.gst-libav}/lib/gstreamer-1.0"

    # Dynamiczne podpinanie systemowych sterowników OpenGL/EGL z NixOS do LD_LIBRARY_PATH
    export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib:${
      pkgs.lib.makeLibraryPath [
        pkgs.glib
        pkgs.gtk3
        pkgs.webkitgtk_4_1
        pkgs.libGL
        pkgs.vulkan-loader
        gst.gstreamer
        gst.gst-plugins-base
        gst.gst-plugins-good
        gst.gst-plugins-bad
        gst.gst-libav
      ]
    }:$LD_LIBRARY_PATH"

    echo "Rust: $(rustc --version)"
    echo "Cargo: $(cargo --version)"
    echo "GStreamer: $(gst-inspect-10 --version | head -n1)"
  '';
}
