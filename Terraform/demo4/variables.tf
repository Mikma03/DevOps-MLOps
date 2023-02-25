variable "filename" {
  default = "abc.txt"
}

variable "content_list" {
  default = ["abc", "def", "ghi", "abc"]
  type    = list
}

variable "content_list_of_a_type" {
  default = ["abc","def","ghi","abc"]
  type = list(string)
}

variable "content_map" {
  default = {
    "value_abc" = "abc",
    "value_def" = "def"
  }
  type = map
}
variable "content_map_of_a_type" {
  default = {
    "permission_abc" = 777
    "permission_def" = 707
  }
  type = map(number)
}

variable "content_set" {
  default = [000,111,707]
  type = set(number)
}

variable "object_cw03a" {
  type = object({
    attribute_1 = string
    attribute_2 = number
    attribute_3 = string
    attribute_4 = string
    attribute_5 = bool
    attribute_6 = string
  })
  default = {
    attribute_1 = "myfile.txt"
    attribute_2 = 777
    attribute_3 = "mycontent"
    attribute_4 = null
    attribute_5 = false
    attribute_6 = "subdirectory"
  }
}