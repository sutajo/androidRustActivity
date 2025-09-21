use jni::{objects::JClass, sys::jstring, JNIEnv};

#[unsafe(no_mangle)]
#[allow(nonstandard_style)]
pub fn Java_com_example_androidRustActivity_MainActivity_stringFromJNI(
    env: JNIEnv,
    _class: JClass,) ->  jstring
{
    env.new_string("Hello from Rust").unwrap().into_raw()
}