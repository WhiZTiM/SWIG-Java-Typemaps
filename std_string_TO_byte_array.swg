/* -----------------------------------------------------------------------------
 * Repurposing of SWIG/Java/std_string.i to map C++'s std::string to Java's byte[]
 *
 *  (C) Ibrahim Timothy Onogu
 *  whiztim@outlook.com
 *
 * Typemaps for std::string and const std::string&
 * These are mapped to a Java String and are passed around by value.
 *
 * To use non-const std::string references use the following %apply.  Note 
 * that they are passed by value.
 * %apply const std::string & {std::string &};
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {

%naturalvar string;

class string;

// string
%typemap(jni) string "jbyteArray"
%typemap(jtype) string "byte[]"
%typemap(jstype) string "byte[]"
%typemap(javadirectorin) string "$jniinput"
%typemap(javadirectorout) string "$javacall"

%typemap(in) string 
%{ if(!$input) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     return $null;
    }
     
    jbyte *$1_pstr = jenv->GetByteArrayElements($input, 0);
    if (!$1_pstr) return $null;
    $1 = std::string( (char*) $1_pstr, jenv->GetArrayLength( $input ));
    jenv->ReleaseByteArrayElements($input, $1_pstr, 0);
%}

%typemap(directorout) string 
%{ if(!$input) {
     if (!jenv->ExceptionCheck()) {
       SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     }
     return $null;
   } 

   jbyte* $1_pstr = jenv->GetByteArrayElements($input, 0);
   if (!$1_pstr) return $null;
   $result = std::string( (char*)$1_pstr, len);
   jenv->ReleaseByteArrayElements($input, $1_pstr, 0);
%}

%typemap(directorin,descriptor="[B") string 
%{ 
    size_t length = $1.size();
    $input = jenv->NewByteArray(length);
    jenv->SetByteArrayRegion($input, 0, length, (const jbyte*)$1.c_str());
   	Swig::LocalRefGuard $1_refguard(jenv, $input);
%}


%typemap(out) string %{ 
	size_t length = $1.size();
    $result = jenv->NewByteArray(length);
    jenv->SetByteArrayRegion($result, 0, length, (const jbyte*)$1.c_str());
	
%}

%typemap(javain) string "$javainput"

%typemap(javaout) string {
    return $jnicall;
  }

%typemap(typecheck) string = char *;

%typemap(throws) string
%{ SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, $1.c_str());
   return $null; %}

// const string &
%typemap(jni) const string & "jbyteArray"
%typemap(jtype) const string & "byte[]"
%typemap(jstype) const string & "byte[]"
%typemap(javadirectorin) const string & "$jniinput"
%typemap(javadirectorout) const string & "$javacall"

%typemap(in) const string &
%{ if(!$input) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     return $null;
   }
      
   jbyte* $1_pstr = jenv->GetByteArrayElements($input, 0);
   if (!$1_pstr) return $null;
   
   $*1_ltype $1_str(std::string((char*)$1_pstr, jenv->GetArrayLength($input)));
   $1 = &$1_str;
   jenv->ReleaseByteArrayElements($input, $1_pstr, 0);
%}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const string &
%{ 
	if(!$input) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null string");
     return $null;
   }
   
   jbyte* $1_pstr = jenv->GetByteArrayElements($input, 0);
   if (!$1_pstr) return $null;
   
   /* possible thread/reentrant code problem */
   static $*1_ltype $1_str;
   $1_str = std::string((char*)$1_pstr, jenv->GetArrayLength($input));
   $result = &$1_str;
   jenv->ReleaseByteArrayElements($input, $1_pstr, 0);
%}


%typemap(directorin,descriptor="[B") const string &
%{
	size_t length = $1.size();
    $input = jenv->NewByteArray(length);
    jenv->SetByteArrayRegion($input, 0, length, (const jbyte*)$1.c_str()); 
	Swig::LocalRefGuard $1_refguard(jenv, $input);
%}

%typemap(out) const string & %{ 
	size_t length = $1->size();
    $result = jenv->NewByteArray(length);
    jenv->SetByteArrayRegion($result, 0, length, (const jbyte*)$1->c_str());
%}

%typemap(javain) const string & "$javainput"

%typemap(javaout) const string & {
    return $jnicall;
  }

%typemap(typecheck) const string & = char *;

%typemap(throws) const string &
%{ SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, $1.c_str());
   return $null; %}

}
