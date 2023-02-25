resource "local_file" "with_list" {
  filename = "my_file_list"
  content = var.content_list[2]
}

resource "local_file" "with_list_of_a_type" {
  filename = "my_file_list_of_a_type"
  content = var.content_list_of_a_type[0]
}

resource "local_file" "with_map" {
  filename = "my_file_map"
  content = var.content_map["value_abc"]
}

resource "local_file" "with_map_of_a_type" {
  filename = "my_file_map_of_a_type"
  content = "map of a type"
  file_permission = var.content_map_of_a_type["permission_abc"]
}

resource "local_file" "with_set" {
  filename = "my_file_set"
  content = "set of a type"
  file_permission = tolist(var.content_set)[2]
}

resource "local_file" "test" {
  filename = "${var.object_cw03a.attribute_6}/${var.object_cw03a.attribute_1}"
  content = var.object_cw03a.attribute_3
  file_permission = var.object_cw03a.attribute_2
}