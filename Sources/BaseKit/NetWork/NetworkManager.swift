//
//  NetworkManager.swift
//  XFVP
//
//  Created by apple on 2025/7/4.
//

import Alamofire
import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case uploadFailed(Error)
    case downloadFailed(Error)
    case serverError(statusCode: Int, message: String?)
    case fileNotFound
    case methodNotAllowed
    case fileTooLarge
    case unsupportedMediaType
}

public final class NetworkManager: @unchecked Sendable {
    public static let shared = NetworkManager()
    
    private let session: Session
    
    public init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 120
        
        session = Session(
            configuration: configuration,
            eventMonitors: [NetworkLogger()]
        )
    }
    
    // MARK: - GET 请求
    public  func get<T: Decodable & Sendable>(
        _ url: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        try await request(
            url: url,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        )
    }
    
    // MARK: - POST 请求
    public  func post<T: Decodable & Sendable>(
        _ url: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        try await request(
            url: url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
    }
    
    // MARK: - 文件上传
    public func uploadFile(
        _ url: String,
        fileURL: URL,
        fieldName: String = "file",
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> UploadResponse {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.upload(
                multipartFormData: { multipart in
                    multipart.append(
                        fileURL,
                        withName: fieldName,
                        fileName: fileURL.lastPathComponent,
                        mimeType: fileURL.mimeType
                    )
                    
                    if let parameters = parameters {
                        for (key, value) in parameters {
                            if let data = "\(value)".data(using: .utf8) {
                                multipart.append(data, withName: key)
                            }
                        }
                    }
                },
                to: url,
                headers: headers
            )
            .uploadProgress { progress in
                progressHandler?(progress.fractionCompleted)
            }
            .responseDecodable(of: UploadResponse.self) { response in
                // 检查状态码
                guard let statusCode = response.response?.statusCode else {
                    continuation.resume(throwing: NetworkError.invalidResponse)
                    return
                }
                print(statusCode, "statusCode")
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: NetworkError.uploadFailed(error))
                }
            }
        }
    }
   
 
    
    // MARK: - 文件下载
    public  func downloadFile(
        _ url: String,
        destination: URL? = nil,
        fileName: String? = nil,
        headers: HTTPHeaders? = nil,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> URL {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        let destination: DownloadRequest.Destination = { temporaryURL, response in
            // 优先使用指定的文件名，否则使用服务器建议的文件名，最后使用默认文件名
                  let finalFileName = fileName ?? url.lastPathComponent
                  
                  let destinationURL = (destination ?? FileManager.default.temporaryDirectory)
                      .appendingPathComponent(finalFileName) // 确保附加文件名
                  
                  print("文件将保存到: \(destinationURL)") // 调试日志
                  return (destinationURL, [.removePreviousFile, .createIntermediateDirectories])
//            let destinationURL = destination ?? FileManager.default.temporaryDirectory
//                .appendingPathComponent(response.suggestedFilename ?? "downloaded_file")
//            
//            return (destinationURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.download(url, to: destination)
                .downloadProgress { progress in
                    progressHandler?(progress.fractionCompleted)
                }
                .response { response in
                    switch response.result {
                    case .success(let fileURL):
                        if let fileURL = fileURL {
                            continuation.resume(returning: fileURL)
                        } else {
                            continuation.resume(throwing: NetworkError.invalidResponse)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: NetworkError.downloadFailed(error))
                    }
                }
        }
    }
    
    // MARK: - POST 文件上传
    /// 使用 POST 方法上传文件
    /// - Parameters:
    ///   - url: 上传接口URL字符串
    ///   - fileURL: 本地文件URL
    ///   - fieldName: 文件字段名（默认为"file"）
    ///   - parameters: 额外参数
    ///   - headers: 自定义请求头
    ///   - progressHandler: 上传进度回调
    /// - Returns: 上传响应数据
    /// - Throws: 网络错误
    // MARK: - POST文件上传（通用风格版）
    public  func postUploadFile<T: Decodable & Sendable>(
        url: String,
        fileURL: URL,
        fieldName: String = "file",
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> T {
        // 1. URL验证
        guard let requestURL = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        // 2. 文件存在性检查
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw NetworkError.fileNotFound
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            // 4. 创建上传请求
            AF.upload(
                multipartFormData: { multipart in
                    multipart.append(
                        fileURL,
                        withName: fieldName,
                        fileName: fileURL.lastPathComponent,
                        mimeType: fileURL.mimeType
                    )
                    
                    parameters?.forEach { key, value in
                        if let data = "\(value)".data(using: .utf8) {
                            multipart.append(data, withName: key)
                        }
                    }
                },
                to: requestURL,
                method: .post
            )
            .uploadProgress { progress in
                progressHandler?(progress.fractionCompleted)
            }
            .responseDecodable(of: T.self) { response in
                // 打印完整响应信息（调试用）
                debugPrint(response)
                
                // 5. 处理响应
                guard let statusCode = response.response?.statusCode else {
                    continuation.resume(throwing: NetworkError.invalidResponse)
                    return
                }
                
                switch response.result {
                case .success(let value):
                    print("请求成功：", value)
                    continuation.resume(returning: value)
                case .failure(_):
                    let errorMessage = String(data: response.data ?? Data(), encoding: .utf8)
                    if statusCode == 405 {
                        continuation.resume(throwing: NetworkError.methodNotAllowed)
                    } else {
                        continuation.resume(throwing: NetworkError.serverError(
                            statusCode: statusCode,
                            message: errorMessage
                        ))
                    }
                }
            }
        }
    }
    
    // MARK: - 通用请求方法
    public  func request<T: Decodable & Sendable >(
        url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?
    ) async throws -> T {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            .responseDecodable(of: T.self) { response in
                // 检查状态码
                guard let statusCode = response.response?.statusCode else {
                    continuation.resume(throwing: NetworkError.invalidResponse)
                    return
                }
                print(statusCode, "statusCode")
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    print("Decoding error:", error.localizedDescription)
                       if let data = response.data {
                           print("Raw response:", String(data: data, encoding: .utf8) ?? "Invalid data")
                       }
                    if let statusCode = response.response?.statusCode {
                        let message = String(data: response.data ?? Data(), encoding: .utf8)
                        continuation.resume(throwing: NetworkError.serverError(
                            statusCode: statusCode,
                            message: message
                        ))
                    } else {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
// 状态码为 200 时尝试解码
//                if statusCode == 200 {
//                    do {
//                        if let data = response.data {
//                            let decodedData = try JSONDecoder().decode(T.self, from: data)
//                            continuation.resume(returning: decodedData)
//                        } else {
//                            continuation.resume(throwing: NetworkError.invalidResponse)
//                        }
//                    } catch let decodingError {
//                        // 解码失败
//                        continuation.resume(throwing: decodingError)
//                    }
//                } else {
//                    // 状态码非 200，返回服务器错误
//                    let errorMessage = String(data: response.data ?? Data(), encoding: .utf8)
//                    continuation.resume(throwing: NetworkError.serverError(
//                        statusCode: statusCode,
//                        message: errorMessage
//                    ))
//                }
// MARK: - 辅助类型和扩展
public struct UploadResponse: Decodable, Sendable {
    let success: Bool
    let message: String?
    let fileUrl: URL?
}

extension URL {
    var mimeType: String {
        // 获取文件扩展名
        let fileExtension = self.pathExtension
    
        return fileExtension
    }
}

// MARK: - 网络请求日志记录器
public final class NetworkLogger: EventMonitor {
    public  func requestDidResume(_ request: Request) {
        print("🌐 [Network Request] \(request.description)")
        
        if let headers = request.request?.allHTTPHeaderFields {
            print("📝 Headers: \(headers)")
        }
        
        if let body = request.request?.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("📦 Body: \(bodyString)")
        }
    }
    
    public func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        guard let statusCode = response.response?.statusCode else { return }
        let statusIcon = (200..<300).contains(statusCode) ? "✅" : "❌"
        print("\(statusIcon) [\(statusCode)] \(request.description)")
        
        if let data = response.data,
           let json = try? JSONSerialization.jsonObject(with: data),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📥 Response: \(jsonString)")
        }
    }
}

