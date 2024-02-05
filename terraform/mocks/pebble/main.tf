resource "null_resource" "start_pebble" {
  provisioner "local-exec" {
    working_dir = path.module
    command = "pebble -config data/pebble-config.json > /dev/null 2>&1 &"
  }
}

resource "null_resource" "stop_pebble" {
  provisioner "local-exec" {
    command = "ps aux | grep pebble | grep -v grep | awk '{print $2}' | xargs kill"
    when = destroy
  }
}
