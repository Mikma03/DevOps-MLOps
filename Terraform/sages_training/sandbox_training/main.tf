resource "local_file" "abc" {
  filename = "abc.txt"
  content = "ab32323c"
}

resource "local_file" "def" {
  filename = "def/def.txt"
  content = "def"
}