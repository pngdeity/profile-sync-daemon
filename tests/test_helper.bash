setup() {
  # Create a temporary directory for the test
  TEST_DIR=$(mktemp -d)
  export TEST_DIR

  # Create directories mimicking the system
  mkdir -p "$TEST_DIR/bin"
  mkdir -p "$TEST_DIR/usr/share/psd/browsers"
  mkdir -p "$TEST_DIR/home/testuser"
  mkdir -p "$TEST_DIR/tmp"
  mkdir -p "$TEST_DIR/run/user/1000" # XDG_RUNTIME_DIR

  # Set environment variables
  export HOME="$TEST_DIR/home/testuser"
  export PATH="$TEST_DIR/bin:$PATH"
  export XDG_RUNTIME_DIR="$TEST_DIR/run/user/1000"
  export XDG_CONFIG_HOME="$HOME/.config"
  export TMPDIR="$TEST_DIR/tmp"

  # Copy necessary files
  cp -r "$BATS_TEST_DIRNAME/../common/browsers/"* "$TEST_DIR/usr/share/psd/browsers/"

  # Mock psd.conf
  mkdir -p "$HOME/.config/psd"
  cat > "$HOME/.config/psd/psd.conf" <<EOF
USE_OVERLAYFS="yes"
BROWSERS="firefox"
EOF

  # Create a dummy firefox profile
  mkdir -p "$HOME/.mozilla/firefox/abcdefgh.default"
  cat > "$HOME/.mozilla/firefox/profiles.ini" <<EOF
[Profile0]
Name=default
IsRelative=1
Path=abcdefgh.default
Default=1
EOF

  # Mock common dependencies
  for cmd in rsync awk gdbus tput; do
    echo "#!/bin/bash" > "$TEST_DIR/bin/$cmd"
    echo "exit 0" >> "$TEST_DIR/bin/$cmd"
    chmod +x "$TEST_DIR/bin/$cmd"
  done

  # Mock modinfo to support overlay
  cat > "$TEST_DIR/bin/modinfo" <<EOF
#!/bin/bash
if [[ "\$1" == "overlay" ]]; then
  exit 0
else
  exit 1
fi
EOF
  chmod +x "$TEST_DIR/bin/modinfo"

  # Mock psd-overlay-helper
  cat > "$TEST_DIR/bin/psd-overlay-helper" <<EOF
#!/bin/bash
echo "psd-overlay-helper called" >> "$TEST_DIR/psd-overlay-helper.log"
exit 0
EOF
  chmod +x "$TEST_DIR/bin/psd-overlay-helper"

  # Mock id
  cat > "$TEST_DIR/bin/id" <<EOF
#!/bin/bash
if [[ "\$1" == "-un" ]]; then
  echo "testuser"
elif [[ "\$1" == "-g" ]]; then
  echo "1000"
else
  echo "1000"
fi
EOF
  chmod +x "$TEST_DIR/bin/id"

  # Mock getent
  cat > "$TEST_DIR/bin/getent" <<EOF
#!/bin/bash
if [[ "\$1" == "passwd" ]] && [[ "\$2" == "testuser" ]]; then
  echo "testuser:x:1000:1000:Test User:$TEST_DIR/home/testuser:/bin/bash"
fi
EOF
  chmod +x "$TEST_DIR/bin/getent"

  # Mock systemctl
  cat > "$TEST_DIR/bin/systemctl" <<EOF
#!/bin/bash
if [[ "\$1" == "--user" ]] && [[ "\$2" == "is-active" ]]; then
  echo "inactive"
fi
EOF
  chmod +x "$TEST_DIR/bin/systemctl"

  # Mock pgrep
  cat > "$TEST_DIR/bin/pgrep" <<EOF
#!/bin/bash
if [[ "\$1" == "-cf" ]]; then
  echo "0"
else
  # Default to not found
  exit 1
fi
EOF
  chmod +x "$TEST_DIR/bin/pgrep"

  # Prepare profile-sync-daemon
  sed -e "s|/usr/share/psd|$TEST_DIR/usr/share/psd|g" \
      -e "s|/usr/bin/psd-overlay-helper|$TEST_DIR/bin/psd-overlay-helper|g" \
      -e 's|@VERSION@|test|g' \
      "$BATS_TEST_DIRNAME/../common/profile-sync-daemon.in" > "$TEST_DIR/bin/profile-sync-daemon"
  chmod +x "$TEST_DIR/bin/profile-sync-daemon"
}

teardown() {
  rm -rf "$TEST_DIR"
}
