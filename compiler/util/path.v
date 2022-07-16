module util

import os

pub fn get_default_lib_path() string {
	return os.getenv('W_DEFAULT_LIB_PATH')
}
