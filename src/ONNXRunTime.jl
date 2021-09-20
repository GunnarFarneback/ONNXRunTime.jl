module ONNXRunTime

# Useful documentation:
# * API reference:https://github.com/microsoft/onnxruntime/blob/v1.8.1/include/onnxruntime/core/session/onnxruntime_c_api.h#L347
# * C usage Example: https://github.com/microsoft/onnxruntime-inference-examples/blob/d031f879c9a8d33c8b7dc52c5bc65fe8b9e3960d/c_cxx/fns_candy_style_transfer/fns_candy_style_transfer.c

# TODO
#
# * Add GC.@preserve in more places
# * We assume that OrtApi is never deleted? Is that true?
# * Should we provide a default const OrtApi for convenience?

using Libdl
using CEnum: @cenum
using ArgCheck
using Pkg.Artifacts: @artifact_str

const LIB_CPU = Ref(C_NULL)
const LIB_GPU = Ref(C_NULL)

const DEVICES = [:cpu, :gpu]

function set_lib!(path::AbstractString, device::Symbol)
    @argcheck ispath(path)
    LIB = libref(device)
    if LIB[] != C_NULL
        dlclose(LIB[])
    end
    LIB[] = dlopen(path)
end

function make_lib!(device)
    @argcheck device in DEVICES
    root = if device === :cpu
        artifact"onnxruntime_cpu"
    elseif device === :gpu
        artifact"onnxruntime_gpu"
    else
        error("Unknown device $(repr(device))")
    end
    @check isdir(root)
    dir = joinpath(root, only(readdir(root)))
    @check isdir(dir)
    path = joinpath(dir, "lib", "libonnxruntime.so")
    set_lib!(path, device)
end

function libref(device::Symbol)::Ref
    @argcheck device in DEVICES
    if device === :cpu
        LIB_CPU
    elseif device === :gpu
        LIB_CPU
    else
        error("Unreachable $(repr(device))")
    end
end

function libptr(device::Symbol)::Ptr
    ref = libref(device)
    if ref[] == C_NULL
        make_lib!(device)
    end
    return ref[]
end

function unsafe_load(ptr::Ptr)
    if ptr == C_NULL
        error("unsafe_load from NULL: $ptr")
    else
        Base.unsafe_load(ptr)
    end
end

################################################################################
##### OrtApi
################################################################################
struct OrtApiBase
    GetApi::Ptr{Cvoid}
    GetVersionString::Ptr{Cvoid}
    # a global constant, never released
end

struct OrtApi
    CreateStatus::Ptr{Cvoid}
    GetErrorCode::Ptr{Cvoid}
    GetErrorMessage::Ptr{Cvoid}
    CreateEnv::Ptr{Cvoid}
    CreateEnvWithCustomLogger::Ptr{Cvoid}
    EnableTelemetryEvents::Ptr{Cvoid}
    DisableTelemetryEvents::Ptr{Cvoid}
    CreateSession::Ptr{Cvoid}
    CreateSessionFromArray::Ptr{Cvoid}
    Run::Ptr{Cvoid}
    CreateSessionOptions::Ptr{Cvoid}
    SetOptimizedModelFilePath::Ptr{Cvoid}
    CloneSessionOptions::Ptr{Cvoid}
    SetSessionExecutionMode::Ptr{Cvoid}
    EnableProfiling::Ptr{Cvoid}
    DisableProfiling::Ptr{Cvoid}
    EnableMemPattern::Ptr{Cvoid}
    DisableMemPattern::Ptr{Cvoid}
    EnableCpuMemArena::Ptr{Cvoid}
    DisableCpuMemArena::Ptr{Cvoid}
    SetSessionLogId::Ptr{Cvoid}
    SetSessionLogVerbosityLevel::Ptr{Cvoid}
    SetSessionLogSeverityLevel::Ptr{Cvoid}
    SetSessionGraphOptimizationLevel::Ptr{Cvoid}
    SetIntraOpNumThreads::Ptr{Cvoid}
    SetInterOpNumThreads::Ptr{Cvoid}
    CreateCustomOpDomain::Ptr{Cvoid}
    CustomOpDomain_Add::Ptr{Cvoid}
    AddCustomOpDomain::Ptr{Cvoid}
    RegisterCustomOpsLibrary::Ptr{Cvoid}
    SessionGetInputCount::Ptr{Cvoid}
    SessionGetOutputCount::Ptr{Cvoid}
    SessionGetOverridableInitializerCount::Ptr{Cvoid}
    SessionGetInputTypeInfo::Ptr{Cvoid}
    SessionGetOutputTypeInfo::Ptr{Cvoid}
    SessionGetOverridableInitializerTypeInfo::Ptr{Cvoid}
    SessionGetInputName::Ptr{Cvoid}
    SessionGetOutputName::Ptr{Cvoid}
    SessionGetOverridableInitializerName::Ptr{Cvoid}
    CreateRunOptions::Ptr{Cvoid}
    RunOptionsSetRunLogVerbosityLevel::Ptr{Cvoid}
    RunOptionsSetRunLogSeverityLevel::Ptr{Cvoid}
    RunOptionsSetRunTag::Ptr{Cvoid}
    RunOptionsGetRunLogVerbosityLevel::Ptr{Cvoid}
    RunOptionsGetRunLogSeverityLevel::Ptr{Cvoid}
    RunOptionsGetRunTag::Ptr{Cvoid}
    RunOptionsSetTerminate::Ptr{Cvoid}
    RunOptionsUnsetTerminate::Ptr{Cvoid}
    CreateTensorAsOrtValue::Ptr{Cvoid}
    CreateTensorWithDataAsOrtValue::Ptr{Cvoid}
    IsTensor::Ptr{Cvoid}
    GetTensorMutableData::Ptr{Cvoid}
    FillStringTensor::Ptr{Cvoid}
    GetStringTensorDataLength::Ptr{Cvoid}
    GetStringTensorContent::Ptr{Cvoid}
    CastTypeInfoToTensorInfo::Ptr{Cvoid}
    GetOnnxTypeFromTypeInfo::Ptr{Cvoid}
    CreateTensorTypeAndShapeInfo::Ptr{Cvoid}
    SetTensorElementType::Ptr{Cvoid}
    SetDimensions::Ptr{Cvoid}
    GetTensorElementType::Ptr{Cvoid}
    GetDimensionsCount::Ptr{Cvoid}
    GetDimensions::Ptr{Cvoid}
    GetSymbolicDimensions::Ptr{Cvoid}
    GetTensorShapeElementCount::Ptr{Cvoid}
    GetTensorTypeAndShape::Ptr{Cvoid}
    GetTypeInfo::Ptr{Cvoid}
    GetValueType::Ptr{Cvoid}
    CreateMemoryInfo::Ptr{Cvoid}
    CreateCpuMemoryInfo::Ptr{Cvoid}
    CompareMemoryInfo::Ptr{Cvoid}
    MemoryInfoGetName::Ptr{Cvoid}
    MemoryInfoGetId::Ptr{Cvoid}
    MemoryInfoGetMemType::Ptr{Cvoid}
    MemoryInfoGetType::Ptr{Cvoid}
    AllocatorAlloc::Ptr{Cvoid}
    AllocatorFree::Ptr{Cvoid}
    AllocatorGetInfo::Ptr{Cvoid}
    GetAllocatorWithDefaultOptions::Ptr{Cvoid}
    AddFreeDimensionOverride::Ptr{Cvoid}
    GetValue::Ptr{Cvoid}
    GetValueCount::Ptr{Cvoid}
    CreateValue::Ptr{Cvoid}
    CreateOpaqueValue::Ptr{Cvoid}
    GetOpaqueValue::Ptr{Cvoid}
    KernelInfoGetAttribute_float::Ptr{Cvoid}
    KernelInfoGetAttribute_int64::Ptr{Cvoid}
    KernelInfoGetAttribute_string::Ptr{Cvoid}
    KernelContext_GetInputCount::Ptr{Cvoid}
    KernelContext_GetOutputCount::Ptr{Cvoid}
    KernelContext_GetInput::Ptr{Cvoid}
    KernelContext_GetOutput::Ptr{Cvoid}
    ReleaseEnv::Ptr{Cvoid}
    ReleaseStatus::Ptr{Cvoid}
    ReleaseMemoryInfo::Ptr{Cvoid}
    ReleaseSession::Ptr{Cvoid}
    ReleaseValue::Ptr{Cvoid}
    ReleaseRunOptions::Ptr{Cvoid}
    ReleaseTypeInfo::Ptr{Cvoid}
    ReleaseTensorTypeAndShapeInfo::Ptr{Cvoid}
    ReleaseSessionOptions::Ptr{Cvoid}
    ReleaseCustomOpDomain::Ptr{Cvoid}
    GetDenotationFromTypeInfo::Ptr{Cvoid}
    CastTypeInfoToMapTypeInfo::Ptr{Cvoid}
    CastTypeInfoToSequenceTypeInfo::Ptr{Cvoid}
    GetMapKeyType::Ptr{Cvoid}
    GetMapValueType::Ptr{Cvoid}
    GetSequenceElementType::Ptr{Cvoid}
    ReleaseMapTypeInfo::Ptr{Cvoid}
    ReleaseSequenceTypeInfo::Ptr{Cvoid}
    SessionEndProfiling::Ptr{Cvoid}
    SessionGetModelMetadata::Ptr{Cvoid}
    ModelMetadataGetProducerName::Ptr{Cvoid}
    ModelMetadataGetGraphName::Ptr{Cvoid}
    ModelMetadataGetDomain::Ptr{Cvoid}
    ModelMetadataGetDescription::Ptr{Cvoid}
    ModelMetadataLookupCustomMetadataMap::Ptr{Cvoid}
    ModelMetadataGetVersion::Ptr{Cvoid}
    ReleaseModelMetadata::Ptr{Cvoid}
    CreateEnvWithGlobalThreadPools::Ptr{Cvoid}
    DisablePerSessionThreads::Ptr{Cvoid}
    CreateThreadingOptions::Ptr{Cvoid}
    ReleaseThreadingOptions::Ptr{Cvoid}
    ModelMetadataGetCustomMetadataMapKeys::Ptr{Cvoid}
    AddFreeDimensionOverrideByName::Ptr{Cvoid}
    GetAvailableProviders::Ptr{Cvoid}
    ReleaseAvailableProviders::Ptr{Cvoid}
    GetStringTensorElementLength::Ptr{Cvoid}
    GetStringTensorElement::Ptr{Cvoid}
    FillStringTensorElement::Ptr{Cvoid}
    AddSessionConfigEntry::Ptr{Cvoid}
    CreateAllocator::Ptr{Cvoid}
    ReleaseAllocator::Ptr{Cvoid}
    RunWithBinding::Ptr{Cvoid}
    CreateIoBinding::Ptr{Cvoid}
    ReleaseIoBinding::Ptr{Cvoid}
    BindInput::Ptr{Cvoid}
    BindOutput::Ptr{Cvoid}
    BindOutputToDevice::Ptr{Cvoid}
    GetBoundOutputNames::Ptr{Cvoid}
    GetBoundOutputValues::Ptr{Cvoid}
    ClearBoundInputs::Ptr{Cvoid}
    ClearBoundOutputs::Ptr{Cvoid}
    TensorAt::Ptr{Cvoid}
    CreateAndRegisterAllocator::Ptr{Cvoid}
    SetLanguageProjection::Ptr{Cvoid}
    SessionGetProfilingStartTimeNs::Ptr{Cvoid}
    SetGlobalIntraOpNumThreads::Ptr{Cvoid}
    SetGlobalInterOpNumThreads::Ptr{Cvoid}
    SetGlobalSpinControl::Ptr{Cvoid}
    AddInitializer::Ptr{Cvoid}
    CreateEnvWithCustomLoggerAndGlobalThreadPools::Ptr{Cvoid}
    SessionOptionsAppendExecutionProvider_CUDA::Ptr{Cvoid}
    SessionOptionsAppendExecutionProvider_ROCM::Ptr{Cvoid}
    SessionOptionsAppendExecutionProvider_OpenVINO::Ptr{Cvoid}
    SetGlobalDenormalAsZero::Ptr{Cvoid}
    CreateArenaCfg::Ptr{Cvoid}
    ReleaseArenaCfg::Ptr{Cvoid}
    ModelMetadataGetGraphDescription::Ptr{Cvoid}
    SessionOptionsAppendExecutionProvider_TensorRT::Ptr{Cvoid}
    SetCurrentGpuDeviceId::Ptr{Cvoid}
    GetCurrentGpuDeviceId::Ptr{Cvoid}
    KernelInfoGetAttributeArray_float::Ptr{Cvoid}
    KernelInfoGetAttributeArray_int64::Ptr{Cvoid}
    CreateArenaCfgV2::Ptr{Cvoid}
    AddRunConfigEntry::Ptr{Cvoid}
    CreatePrepackedWeightsContainer::Ptr{Cvoid}
    ReleasePrepackedWeightsContainer::Ptr{Cvoid}
    CreateSessionWithPrepackedWeightsContainer::Ptr{Cvoid}
    CreateSessionFromArrayWithPrepackedWeightsContainer::Ptr{Cvoid}
end

const OrtStatusPtr = Ptr{Cvoid}

function OrtGetApiBase(;device=:cpu)
    @argcheck device in DEVICES
    f = dlsym(libptr(device), :OrtGetApiBase)
    api_base = unsafe_load(@ccall $f()::Ptr{OrtApiBase})
end
function GetVersionString(api_base::OrtApiBase)::String
    return unsafe_string(@ccall $(api_base.GetVersionString)()::Cstring)
end

const ORT_API_VERSION = 8
function GetApi(api_base::OrtApiBase, ORT_API_VERSION=ORT_API_VERSION)::OrtApi
    ptr = @ccall $(api_base.GetApi)(ORT_API_VERSION::Int)::Ptr{OrtApi}
    unsafe_load(ptr)
end
"""
Convenience method.
"""
GetApi(;device=:cpu) = GetApi(OrtGetApiBase(;device))

################################################################################
##### OrtEnv
################################################################################
for Obj in [
        :Env                      ,
        :Status                   ,
        :MemoryInfo               ,
        :IoBinding                ,
        :Session                  ,
        :Value                    ,
        :RunOptions               ,
        :TypeInfo                 ,
        :TensorTypeAndShapeInfo   ,
        :SessionOptions           ,
        :CustomOpDomain           ,
        :MapTypeInfo              ,
        :SequenceTypeInfo         ,
        :ModelMetadata            ,
        #:ThreadPoolParams         ,
        :ThreadingOptions         ,
        :ArenaCfg                 ,
        :PrepackedWeightsContainer,
   ]
    OrtObj     = Symbol(:Ort    , Obj)
    ReleaseObj = Symbol(:Release, Obj)
    if !(ReleaseObj in fieldnames(OrtApi))
        error("$ReleaseObj not in fieldnames(OrtApi)")
    end
    @eval mutable struct $OrtObj
        ptr::Ptr{Cvoid}
    end
    @eval function $ReleaseObj(api::OrtApi, obj::$OrtObj)
        f = api.$ReleaseObj
        ccall(f, Cvoid, (Ptr{Cvoid},), obj.ptr)
    end
    @eval function release(api::OrtApi, obj::$OrtObj)
        $ReleaseObj(api, obj)
    end
    @eval export $OrtObj
end

function into_julia(::Type{T}, api::OrtApi, objptr::Ref{Ptr{Cvoid}}, status_ptr::Ptr{Cvoid})::T where {T}
    discharge_status_ptr(api, status_ptr)
    ptr = objptr[]
    if ptr == C_NULL
        error("Unexpected Null ptr");
    end
    ret = T(ptr)
    finalizer(ret) do obj
        release(api, obj)
    end
    return ret
end

@cenum OrtLoggingLevel::UInt32 begin
    ORT_LOGGING_LEVEL_VERBOSE = 0
    ORT_LOGGING_LEVEL_INFO = 1
    ORT_LOGGING_LEVEL_WARNING = 2
    ORT_LOGGING_LEVEL_ERROR = 3
    ORT_LOGGING_LEVEL_FATAL = 4
end


function GetErrorMessage(api::OrtApi, status::OrtStatusPtr)::String
    @argcheck status isa Ptr
    @argcheck status != C_NULL
    s = @ccall $(api.GetErrorMessage)(status::Ptr{Cvoid})::Cstring
    unsafe_string(s)
end
function discharge_status_ptr(api, status::OrtStatusPtr)
    if status != C_NULL
        msg = GetErrorMessage(api, status)
        release(api, OrtStatus(status))
        error(msg)
    end
end


function CreateEnv(api::OrtApi;
                    logging_level::OrtLoggingLevel=ORT_LOGGING_LEVEL_WARNING,
                    name::AbstractString,
    )
    p_ptr = Ref(C_NULL)
    status = @ccall $(api.CreateEnv)(logging_level::OrtLoggingLevel, name::Cstring, p_ptr::Ptr{Ptr{Cvoid}})::OrtStatusPtr
    into_julia(OrtEnv, api, p_ptr, status)
end

################################################################################
##### SessionOptions
################################################################################

function CreateSessionOptions(api::OrtApi)
    p_ptr = Ref(C_NULL)
    status = @ccall $(api.CreateSessionOptions)(p_ptr::Ptr{Ptr{Cvoid}})::OrtStatusPtr
    into_julia(OrtSessionOptions, api, p_ptr, status)
end

################################################################################
##### Session
################################################################################

function CreateSession(api::OrtApi, env::OrtEnv, path::AbstractString,
                       options::OrtSessionOptions= CreateSessionOptions(api)
                      )::OrtSession
    @argcheck ispath(path)
    p_ptr = Ref(C_NULL)
    status = @ccall $(api.CreateSession)(env.ptr::Ptr{Cvoid},
            path::Cstring,
            options.ptr::Ptr{Cvoid},
            p_ptr::Ptr{Ptr{Cvoid}})::OrtStatusPtr
    into_julia(OrtSession, api, p_ptr, status)
end

function SessionGetInputCount(api::OrtApi, sess::OrtSession)::Csize_t
    out = Ref{Csize_t}()
    status = @ccall $(api.SessionGetInputCount)(sess.ptr::Ptr{Cvoid}, out::Ptr{Csize_t})::OrtStatusPtr
    discharge_status_ptr(api, status)
    return out[]
end
function SessionGetOutputCount(api::OrtApi, sess::OrtSession)::Csize_t
    out = Ref{Csize_t}()
    status = @ccall $(api.SessionGetOutputCount)(sess.ptr::Ptr{Cvoid}, out::Ptr{Csize_t})::OrtStatusPtr
    discharge_status_ptr(api, status)
    return out[]
end

################################################################################
##### OrtMemoryInfo
################################################################################

@cenum OrtAllocatorType::Int32 begin
    Invalid = -1
    OrtDeviceAllocator = 0
    OrtArenaAllocator = 1
end

@cenum OrtMemType::Int32 begin
    OrtMemTypeCPUInput = -2
    OrtMemTypeCPUOutput = -1
    OrtMemTypeCPU = -1
    OrtMemTypeDefault = 0
end

function CreateCpuMemoryInfo(api::OrtApi;
    allocator_type=OrtArenaAllocator,
    mem_type=OrtMemTypeDefault)

    p_ptr = Ref(C_NULL)
    status = @ccall $(api.CreateCpuMemoryInfo)(allocator_type::OrtAllocatorType,
                                      mem_type::OrtMemType,
                                      p_ptr::Ptr{Ptr{Cvoid}})::OrtStatusPtr
    into_julia(OrtMemoryInfo, api, p_ptr, status)
end

@cenum ONNXTensorElementDataType::UInt32 begin
    ONNX_TENSOR_ELEMENT_DATA_TYPE_UNDEFINED = 0
    ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT = 1
    ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT8 = 2
    ONNX_TENSOR_ELEMENT_DATA_TYPE_INT8 = 3
    ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT16 = 4
    ONNX_TENSOR_ELEMENT_DATA_TYPE_INT16 = 5
    ONNX_TENSOR_ELEMENT_DATA_TYPE_INT32 = 6
    ONNX_TENSOR_ELEMENT_DATA_TYPE_INT64 = 7
    ONNX_TENSOR_ELEMENT_DATA_TYPE_STRING = 8
    ONNX_TENSOR_ELEMENT_DATA_TYPE_BOOL = 9
    ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT16 = 10
    ONNX_TENSOR_ELEMENT_DATA_TYPE_DOUBLE = 11
    ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT32 = 12
    ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT64 = 13
    ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX64 = 14
    ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX128 = 15
    ONNX_TENSOR_ELEMENT_DATA_TYPE_BFLOAT16 = 16
end

const JULIA_TYPE_FROM_ONNX = Dict{ONNXTensorElementDataType, Type}()
function juliatype(onnx::ONNXTensorElementDataType)::Type
    JULIA_TYPE_FROM_ONNX[onnx]
end
for (onnx, T) in [
    #(ONNX_TENSOR_ELEMENT_DATA_TYPE_UNDEFINED  ,
    (ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT      , Cfloat ),
    (ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT8      , UInt8  ),
    (ONNX_TENSOR_ELEMENT_DATA_TYPE_INT8       , Int8   ),
    (ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT16     , UInt16 ),
    (ONNX_TENSOR_ELEMENT_DATA_TYPE_INT16      , Int16  ),
    (ONNX_TENSOR_ELEMENT_DATA_TYPE_INT32      , Int32  ),
    (ONNX_TENSOR_ELEMENT_DATA_TYPE_INT64      , Int64  ),
    (ONNX_TENSOR_ELEMENT_DATA_TYPE_STRING     , Cstring),
    # (ONNX_TENSOR_ELEMENT_DATA_TYPE_BOOL       ,
    # (ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT16    ,
    (ONNX_TENSOR_ELEMENT_DATA_TYPE_DOUBLE     , Cdouble),
    (ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT32     , UInt32 ),
    (ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT64     , UInt64 ),
    # (ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX64  ,
    # (ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX128 ,
    # (ONNX_TENSOR_ELEMENT_DATA_TYPE_BFLOAT16   ,
    ]
    @eval ONNXTensorElementDataType(::Type{$T}) = $onnx
    JULIA_TYPE_FROM_ONNX[onnx] = T
end

function IsTensor(api::OrtApi, val::OrtValue)::Bool
    out = Ref(Cint(0))
    status = @ccall $(api.IsTensor)(val.ptr::Ptr{Cvoid}, out::Ptr{Cint})::OrtStatusPtr
    discharge_status_ptr(api, status)
    return Bool(out[])
end

function GetTensorElementType(api::OrtApi, o::OrtTensorTypeAndShapeInfo)::ONNXTensorElementDataType
    # https://github.com/microsoft/onnxruntime/blob/1886f1a737fb3aa891dea213e076a091002e083f/onnxruntime/core/framework/tensor_type_and_shape.cc#L54
    p_out = Ref{ONNXTensorElementDataType}()
    GC.@preserve o begin
        status = @ccall $(api.GetTensorElementType)(o.ptr::Ptr{Cvoid}, p_out::Ptr{ONNXTensorElementDataType})::OrtStatusPtr
        discharge_status_ptr(api, status)
        p_out[]
    end
end

function GetDimensionsCount(api::OrtApi, o::OrtTensorTypeAndShapeInfo)::Csize_t
    p_out = Ref{Csize_t}()
    GC.@preserve o begin
        status = @ccall $(api.GetDimensionsCount)(o.ptr::Ptr{Cvoid}, p_out::Ptr{Csize_t})::OrtStatusPtr
        discharge_status_ptr(api, status)
        p_out[]
    end
end

function GetDimensions(api::OrtApi, o::OrtTensorTypeAndShapeInfo,
        ndims = GetDimensionsCount(api, o)
    )::Vector{Int64}
    out   = Vector{Int64}(undef, ndims)
    GC.@preserve out o begin
        status = @ccall $(api.GetDimensions)(api::OrtApi,
                o.ptr::Ptr{Cvoid},
                pointer(out)::Ptr{Int64},
                ndims::Csize_t,
        )::OrtStatusPtr
        discharge_status_ptr(api, status)
        return out
    end
end

function GetTensorTypeAndShape(api::OrtApi, o::OrtValue)
    p_ptr = Ref(C_NULL)
    GC.@preserve o begin
        status = @ccall $(api.GetTensorTypeAndShape)(o.ptr::Ptr{Cvoid}, p_ptr::Ptr{Ptr{Cvoid}})::OrtStatusPtr
        into_julia(OrtTensorTypeAndShapeInfo, api, p_ptr, status)
    end
end

function CreateTensorWithDataAsOrtValue(
    api::OrtApi,
    memory_info::OrtMemoryInfo,
    data::Array)::OrtValue

    shapevec = collect(Int64, size(data))
    onnx_elty = ONNXTensorElementDataType(eltype(data))

    p_ptr = Ref(C_NULL)

    # https://github.com/microsoft/onnxruntime/blob/e2194797a713f19a15ce2afbe0c6a78d5d8c467e/onnxruntime/core/session/onnxruntime_c_api.cc#L207
    # ORT_API_STATUS_IMPL(
    #   OrtApis::CreateTensorWithDataAsOrtValue,
    #   _In_ const OrtMemoryInfo* info,
    #   _Inout_ void* p_data,
    #   size_t p_data_len,
    #   _In_ const int64_t* shape,
    #   size_t shape_len,
    #   ONNXTensorElementDataType type,
    #   _Outptr_ OrtValue** out
    # )
    gchandles = (data, memory_info, shapevec)
    GC.@preserve gchandles begin
        info      ::Ptr{Cvoid} = memory_info.ptr
        p_data    ::Ptr{Cvoid} = pointer(data)
        p_data_len::Csize_t    = length(data)*sizeof(eltype(data))
        shape     ::Ptr{Int64} = pointer(shapevec)
        shape_len ::Csize_t    = length(shapevec)
        status = @ccall $(api.CreateTensorWithDataAsOrtValue)(
            info      ::Ptr{Cvoid},
            p_data    ::Ptr{Cvoid},
            p_data_len::Csize_t   ,
            shape     ::Ptr{Int64},
            shape_len ::Csize_t   ,
            onnx_elty ::ONNXTensorElementDataType,
            p_ptr     ::Ptr{Ptr{Cvoid}},
        )::OrtStatusPtr
    end
    return into_julia(OrtValue, api, p_ptr, status)
end

"""
This function is unsafe, because its output points to memory owned by `tensor`.
"""
function unsafe_GetTensorMutableData(api::OrtApi, tensor::OrtValue)::Array
    p_ptr = Ref(C_NULL)
    GC.@preserve tensor begin
        status = @ccall $(api.GetTensorMutableData)(
            tensor.ptr::Ptr{Cvoid},
            p_ptr::Ptr{Ptr{Cvoid}},
        )::OrtStatusPtr
    end
    discharge_status_ptr(api, status)
    info      = GetTensorTypeAndShape(api, tensor)
    ONNX_type = GetTensorElementType(api, info)
    T         = juliatype(ONNX_type)
    shape     = Tuple(GetDimensions(api,info))
    ptrT      = Ptr{T}(p_ptr[])
    return unsafe_wrap(Array, ptrT, shape, own=false)
end
function GetTensorMutableData!(out::AbstractArray, api::OrtApi, tensor::OrtValue)
    GC.@preserve tensor begin
        data_owned_by_tensor = unsafe_GetTensorMutableData(api, tensor)
        copy!(out, data_owned_by_tensor)
    end
    return out
end
function GetTensorMutableData(api::OrtApi, tensor::OrtValue)::Array
    GC.@preserve tensor begin
        data_owned_by_tensor = unsafe_GetTensorMutableData(api, tensor)
        copy(data_owned_by_tensor)
    end
end

function CreateRunOptions(api::OrtApi)::OrtRunOptions
    p_ptr = Ref(C_NULL)
    status = @ccall $(api.CreateRunOptions)(p_ptr::Ptr{Ptr{Cvoid}})::OrtStatusPtr
    into_julia(OrtRunOptions, api, p_ptr, status)
end

function Run(api::OrtApi, session::OrtSession, run_options::OrtRunOptions,
             input_names::Vector{String},
             inputs::Vector{OrtValue},
             output_names::Vector{String})

    @argcheck length(input_names) == length(inputs)

    input_len = length(input_names)
    output_names_len = length(output_names)
    _input_names = Cstring[Base.unsafe_convert(Cstring, s) for s in input_names]
    _output_names = Cstring[Base.unsafe_convert(Cstring, s) for s in output_names]
    _inputs = Ptr{Cvoid}[(inp::OrtValue).ptr for inp in inputs]
    _outputs = Ptr{Cvoid}[C_NULL for _ in 1:output_names_len]

    gchandles = (;
                 session, run_options, input_names, inputs, output_names,
                 _input_names, _inputs, _outputs
                )
    GC.@preserve gchandles begin
        status = @ccall $(api.Run)(
            session.ptr     ::Ptr{Cvoid},
            #run_options.ptr ::Ptr{Cvoid},
            C_NULL ::Ptr{Cvoid},
            _input_names    ::Ptr{Cstring},
            _inputs         ::Ptr{Ptr{Cvoid}},
            input_len       ::Csize_t,
            _output_names   ::Ptr{Cstring},
            output_names_len::Csize_t,
            _outputs        ::Ptr{Ptr{Cvoid}}
        )::OrtStatusPtr
        discharge_status_ptr(api, status)
        outdims = (output_names_len,)
        outputs = map(_outputs) do ptr
            out = OrtValue(ptr)
            finalizer(out) do val
                release(api, val)
            end
            out
        end
        return outputs
    end
end

  # ORT_API2_STATUS(Run, _Inout_ OrtSession* session, _In_opt_ const OrtRunOptions* run_options,
  #                 _In_reads_(input_len) const char* const* input_names,
  #                 _In_reads_(input_len) const OrtValue* const* inputs, size_t input_len,
  #                 _In_reads_(output_names_len) const char* const* output_names, size_t output_names_len,
  #                 _Inout_updates_all_(output_names_len) OrtValue** outputs);


################################################################################
##### testdatapath
################################################################################
function testdatapath(args...)
    joinpath(@__DIR__, "..", "test", "data", args...)
end

################################################################################
##### exports
################################################################################
export OrtApiBase, GetApi, GetVersionString
export OrtApi
export ONNXTensorElementDataType
export release
for f in fieldnames(OrtApi)
    if isdefined(@__MODULE__, f)
        @eval export $f
    end
end

end #module