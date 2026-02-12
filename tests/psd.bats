#!/usr/bin/env bats

load test_helper

@test "config_check uses doas when available" {
  # Mock doas
  cat > "$TEST_DIR/bin/doas" <<EOF
#!/bin/bash
echo "doas called with: \$@" >> "$TEST_DIR/doas.log"
if [[ "\$1" == "-n" ]]; then
    shift
fi
"\$@"
EOF
  chmod +x "$TEST_DIR/bin/doas"

  # Mock sudo (should not be called)
  cat > "$TEST_DIR/bin/sudo" <<EOF
#!/bin/bash
echo "sudo called with: \$@" >> "$TEST_DIR/sudo.log"
exit 1
EOF
  chmod +x "$TEST_DIR/bin/sudo"

  run profile-sync-daemon preview

  if [ "$status" -ne 0 ]; then
    echo "Command failed with status $status"
    echo "Output: $output"
  fi
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/doas.log" ]
  [ ! -f "$TEST_DIR/sudo.log" ]
  grep "psd-overlay-helper" "$TEST_DIR/doas.log"
}

@test "config_check uses sudo when doas is missing" {
  # Ensure doas is missing (it shouldn't be there from setup, but just in case)
  rm -f "$TEST_DIR/bin/doas"

  # Mock sudo
  cat > "$TEST_DIR/bin/sudo" <<EOF
#!/bin/bash
echo "sudo called with: \$@" >> "$TEST_DIR/sudo.log"
if [[ "\$1" == "-kn" ]]; then
    shift
fi
"\$@"
EOF
  chmod +x "$TEST_DIR/bin/sudo"

  run profile-sync-daemon preview

  if [ "$status" -ne 0 ]; then
    echo "Command failed with status $status"
    echo "Output: $output"
  fi
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/sudo.log" ]
  grep "psd-overlay-helper" "$TEST_DIR/sudo.log"
}
