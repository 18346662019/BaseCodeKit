//
//  FileManager.swift
//  fff
//
//  Created by apple on 2026/1/23.
//

import Foundation
public class FileManagerFactory {
    public static func fileExists(pathUrl: URL) -> Bool {
        return FileManager.default.fileExists(atPath: pathUrl.path)
    }
    
    public static func fileRemove(pathUrl: URL) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: pathUrl.path)
            return true
        } catch {
            print("fileRemove \(error)")
            return false
        }
    }
    
    public static func fileMove(from sourceURL: URL, to destinationURL: URL) -> Bool? {
        do {
            if fileExists(pathUrl: destinationURL) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
            return true
        } catch {
            print("fileMove \(error)")
            return false
        }
    }
    
    public static func fileCreate(_ pathUrl: URL) -> Bool? {
        do {
            try FileManager.default.createDirectory(at: pathUrl, withIntermediateDirectories: true)
            return true
        } catch {
            print("\(error)")
            return false
        }
    }
    
    public static func fileCopyItem(from sourceURL: URL, to destinationURL: URL) -> Bool {
        do {
            if fileExists(pathUrl: sourceURL) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return true
        } catch {
            print(" fileCopyItem \(error)")
            return false
        }
    }
    
    public static func contentsOfDirector(at pathUrl: URL) -> [URL]? {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: pathUrl, includingPropertiesForKeys: nil)
            return urls
        } catch {
            print("contentsOfDirector \(error)")
            return nil
        }
    }
    
    // 这个方法有两个作用：
    // 1. 返回 Bool：路径是否存在
    // 2. 通过 inout 参数返回：是否是目录  是否是文件夹
    public static func isDirectory(at pathUrl: URL) -> Bool {
        var isDirectory: ObjCBool = false
        _ = FileManager.default.fileExists(atPath: pathUrl.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    //file: tmp/tepzip
    public static func recursiveContentsOfDirectory(at pathUrl: URL) -> [URL]? {
        //判断是否是目录
        guard isDirectory(at: pathUrl) else { return nil }
        // 便利这个文件夹 或者是目录
        let enumerator = FileManager.default.enumerator(at: pathUrl, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
        var urls: [URL] = []
        while let url = enumerator?.nextObject() as? URL {
            urls.append(url)
        }
        return urls
    }
    
    public static func fileSize(at pathUrl: URL) -> Int64? {
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: pathUrl.path)
            return attribute[.size] as? Int64
        } catch {
            print("fileSize \(error)")
            return nil
        }
    }
    
    public static func creationDate(of pathUrl: URL) -> Date? {
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: pathUrl.path)
            return attribute[.creationDate] as? Date
        } catch {
            print("creationDate \(error)")
            return nil
        }
    }
    
    public static var documentsDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    public static var cacheDirectory: URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    public static var tempDirectory: URL {
        return FileManager.default.temporaryDirectory
    }
    //获取磁盘可用空间
    public static var availabelDiskSpace: Int64? {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            return systemAttributes[.systemFreeSize] as? Int64
        } catch {
            print("availabelDiskSpace \(error)")
            return nil
        }
    }
    public static var totalDiskSpace: Int64? {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            return systemAttributes[.systemSize] as? Int64
        } catch {
            print("totalDiskSpace \(error)")
            return nil
        }
    }
    
}
