#include "DatatipCreate.hxx"
/* Generated by GIWS (version 2.0.1) with command:
giws --disable-return-size-array --output-dir . --throws-exception-on-error --description-file Datatip.giws.xml 
*/
/*

This is generated code.

This software is a computer program whose purpose is to hide the complexity
of accessing Java objects/methods from C++ code.

This software is governed by the CeCILL-B license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the CeCILL-B
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the CeCILL-B license and that you accept its terms.
*/

namespace org_scilab_modules_gui_datatip {

                // Static declarations (if any)
                
// Returns the current env

JNIEnv * DatatipCreate::getCurrentEnv() {
JNIEnv * curEnv = NULL;
jint res=this->jvm->AttachCurrentThread(reinterpret_cast<void **>(&curEnv), NULL);
if (res != JNI_OK) {
throw GiwsException::JniException(getCurrentEnv());
}
return curEnv;
}
// Destructor

DatatipCreate::~DatatipCreate() {
JNIEnv * curEnv = NULL;
this->jvm->AttachCurrentThread(reinterpret_cast<void **>(&curEnv), NULL);

curEnv->DeleteGlobalRef(this->instance);
curEnv->DeleteGlobalRef(this->instanceClass);
}
// Constructors
DatatipCreate::DatatipCreate(JavaVM * jvm_) {
jmethodID constructObject = NULL ;
jobject localInstance ;
jclass localClass ;

const std::string construct="<init>";
const std::string param="()V";
jvm=jvm_;

JNIEnv * curEnv = getCurrentEnv();

localClass = curEnv->FindClass( this->className().c_str() ) ;
if (localClass == NULL) {
  throw GiwsException::JniClassNotFoundException(curEnv, this->className());
}

this->instanceClass = static_cast<jclass>(curEnv->NewGlobalRef(localClass));

/* localClass is not needed anymore */
curEnv->DeleteLocalRef(localClass);

if (this->instanceClass == NULL) {
throw GiwsException::JniObjectCreationException(curEnv, this->className());
}


constructObject = curEnv->GetMethodID( this->instanceClass, construct.c_str() , param.c_str() ) ;
if(constructObject == NULL){
throw GiwsException::JniObjectCreationException(curEnv, this->className());
}

localInstance = curEnv->NewObject( this->instanceClass, constructObject ) ;
if(localInstance == NULL){
throw GiwsException::JniObjectCreationException(curEnv, this->className());
}
 
this->instance = curEnv->NewGlobalRef(localInstance) ;
if(this->instance == NULL){
throw GiwsException::JniObjectCreationException(curEnv, this->className());
}
/* localInstance not needed anymore */
curEnv->DeleteLocalRef(localInstance);

                /* Methods ID set to NULL */
jintcreateDatatipProgramCoordjintintjdoubleArray_doubledoubleID=NULL;
jintcreateDatatipProgramIndexjintintjintintID=NULL;
voiddatatipSetInterpjintintjbooleanbooleanID=NULL;


}

DatatipCreate::DatatipCreate(JavaVM * jvm_, jobject JObj) {
        jvm=jvm_;

        JNIEnv * curEnv = getCurrentEnv();

jclass localClass = curEnv->GetObjectClass(JObj);
        this->instanceClass = static_cast<jclass>(curEnv->NewGlobalRef(localClass));
        curEnv->DeleteLocalRef(localClass);

        if (this->instanceClass == NULL) {
throw GiwsException::JniObjectCreationException(curEnv, this->className());
        }

        this->instance = curEnv->NewGlobalRef(JObj) ;
        if(this->instance == NULL){
throw GiwsException::JniObjectCreationException(curEnv, this->className());
        }
        /* Methods ID set to NULL */
        jintcreateDatatipProgramCoordjintintjdoubleArray_doubledoubleID=NULL;
jintcreateDatatipProgramIndexjintintjintintID=NULL;
voiddatatipSetInterpjintintjbooleanbooleanID=NULL;


}

// Generic methods

void DatatipCreate::synchronize() {
if (getCurrentEnv()->MonitorEnter(instance) != JNI_OK) {
throw GiwsException::JniMonitorException(getCurrentEnv(), "DatatipCreate");
}
}

void DatatipCreate::endSynchronize() {
if ( getCurrentEnv()->MonitorExit(instance) != JNI_OK) {
throw GiwsException::JniMonitorException(getCurrentEnv(), "DatatipCreate");
}
}
// Method(s)

int DatatipCreate::createDatatipProgramCoord (JavaVM * jvm_, int polylineUid, double const* coordDoubleXY, int coordDoubleXYSize){

JNIEnv * curEnv = NULL;
jvm_->AttachCurrentThread(reinterpret_cast<void **>(&curEnv), NULL);
jclass cls = curEnv->FindClass( className().c_str() );

jmethodID jintcreateDatatipProgramCoordjintintjdoubleArray_doubledoubleID = curEnv->GetStaticMethodID(cls, "createDatatipProgramCoord", "(I[D)I" ) ;
if (jintcreateDatatipProgramCoordjintintjdoubleArray_doubledoubleID == NULL) {
throw GiwsException::JniMethodNotFoundException(curEnv, "createDatatipProgramCoord");
}

jdoubleArray coordDoubleXY_ = curEnv->NewDoubleArray( coordDoubleXYSize ) ;

if (coordDoubleXY_ == NULL)
{
// check that allocation succeed
throw GiwsException::JniBadAllocException(curEnv);
}

curEnv->SetDoubleArrayRegion( coordDoubleXY_, 0, coordDoubleXYSize, (jdouble*)(coordDoubleXY) ) ;


                        jint res =  static_cast<jint>( curEnv->CallStaticIntMethod(cls, jintcreateDatatipProgramCoordjintintjdoubleArray_doubledoubleID ,polylineUid, coordDoubleXY_));
                        curEnv->DeleteLocalRef(coordDoubleXY_);
curEnv->DeleteLocalRef(cls);
if (curEnv->ExceptionCheck()) {
throw GiwsException::JniCallMethodException(curEnv);
}
return res;

}

int DatatipCreate::createDatatipProgramIndex (JavaVM * jvm_, int polylineUid, int indexPoint){

JNIEnv * curEnv = NULL;
jvm_->AttachCurrentThread(reinterpret_cast<void **>(&curEnv), NULL);
jclass cls = curEnv->FindClass( className().c_str() );

jmethodID jintcreateDatatipProgramIndexjintintjintintID = curEnv->GetStaticMethodID(cls, "createDatatipProgramIndex", "(II)I" ) ;
if (jintcreateDatatipProgramIndexjintintjintintID == NULL) {
throw GiwsException::JniMethodNotFoundException(curEnv, "createDatatipProgramIndex");
}

                        jint res =  static_cast<jint>( curEnv->CallStaticIntMethod(cls, jintcreateDatatipProgramIndexjintintjintintID ,polylineUid, indexPoint));
                        curEnv->DeleteLocalRef(cls);
if (curEnv->ExceptionCheck()) {
throw GiwsException::JniCallMethodException(curEnv);
}
return res;

}

void DatatipCreate::datatipSetInterp (JavaVM * jvm_, int datatipUid, bool interpMode){

JNIEnv * curEnv = NULL;
jvm_->AttachCurrentThread(reinterpret_cast<void **>(&curEnv), NULL);
jclass cls = curEnv->FindClass( className().c_str() );

jmethodID voiddatatipSetInterpjintintjbooleanbooleanID = curEnv->GetStaticMethodID(cls, "datatipSetInterp", "(IZ)V" ) ;
if (voiddatatipSetInterpjintintjbooleanbooleanID == NULL) {
throw GiwsException::JniMethodNotFoundException(curEnv, "datatipSetInterp");
}

jboolean interpMode_ = (static_cast<bool>(interpMode) ? JNI_TRUE : JNI_FALSE);

                         curEnv->CallStaticVoidMethod(cls, voiddatatipSetInterpjintintjbooleanbooleanID ,datatipUid, interpMode_);
                        curEnv->DeleteLocalRef(cls);
if (curEnv->ExceptionCheck()) {
throw GiwsException::JniCallMethodException(curEnv);
}
}

}