//
//  ImageProvider.swift
//  FlickrFindr
//
//  Created by Aaron Martinez on 9/20/19.
//  Copyright © 2019 Aaron Martinez. All rights reserved.
//

import UIKit

enum ImageProviderError: Error {
    case failedToConstructURL
    case failedToUnwrapData
    case networkError(Error)
    case failedToDecodeObject(Error)
}

class ImageProvider {

    private let baseURL = URL(string: "https://api.flickr.com/services/rest")!
    private let apiKey = "1508443e49213ff84d566777dc211f2a"

    // Flickr API url parameter keys
    private static let methodUrlParameterKey = "method"
    private static let apiKeyUrlParameterKey = "api_key"
    private static let formatUrlParameterKey = "format"
    private static let noJsonCallbackUrlParameterKey = "nojsoncallback"
    private static let perPageUrlParameterKey = "per_page"
    private static let pageUrlParameterKey = "page"
    private static let textUrlParameterKey = "text"

    private let cache = NSCache<NSURL, UIImage>()

    private(set) var photos = [Photo]()

    private var currentSearchTerm = ""
    private var currentPage = 0

    func fetchPhotos(for searchTerm: String, page: Int = 1, completion: @escaping(Result<[Photo],ImageProviderError>) -> Void) {

        guard let photosSearchURL = searchURL(for: searchTerm, page: page) else { return completion(.failure(.failedToConstructURL)) }

        currentSearchTerm = searchTerm
        currentPage = page

        URLSession.shared.dataTask(with: photosSearchURL) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
            }

            guard let data = data else { return completion(.failure(.failedToUnwrapData)) }

            let decoder = JSONDecoder()
            do {
                let photos = try decoder.decode(TopLevelObject.self, from: data).photosDictionary.photos

                if page > 0 {
                    self?.photos.append(contentsOf: photos)
                } else {
                    self?.photos = photos
                }
                completion(.success(photos))
            } catch {
                completion(.failure(.failedToDecodeObject(error)))
            }

        }.resume()
    }

    func fetchNext(completion: @escaping(Result<[Photo],ImageProviderError>) -> Void) {
        let nextPage = currentPage + 1
        fetchPhotos(for: currentSearchTerm, page: nextPage, completion: completion)
    }

    // Photo search url format https://api.flickr.com/services/rest?method=flickr.photos.search&api_key=1508443e49213ff84d566777dc211f2a&text=dog&format=json&per_page=25
    private func searchURL(for searchTerm: String, page: Int) -> URL? {
        let parameters = [
            ImageProvider.methodUrlParameterKey:"flickr.photos.search",
            ImageProvider.apiKeyUrlParameterKey:apiKey,
            ImageProvider.formatUrlParameterKey:"json",
            ImageProvider.noJsonCallbackUrlParameterKey:"1",
            ImageProvider.pageUrlParameterKey:String(page),
            ImageProvider.perPageUrlParameterKey:"25",
            ImageProvider.textUrlParameterKey:searchTerm
        ]
        let queryItems = parameters.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems

        return urlComponents?.url
    }

    // Image request url format
    // https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg

    func fetchImage(for photo: Photo, completion: @escaping(Result<UIImage,ImageProviderError>) -> Void) {

        let urlString = "https://farm" + String(photo.farmID) + ".staticflickr.com"
        guard let url = URL(string: urlString)?
            .appendingPathComponent(photo.serverID)
            .appendingPathComponent("\(photo.imageID)_\(photo.secret)")
            .appendingPathExtension("jpg"),
            let nsUrl = NSURL(string: url.absoluteString)
            else { return completion(.failure(.failedToConstructURL)) }

        if let image = cache.object(forKey: nsUrl) {
            return completion(.success(image))
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
            }

            guard let data = data,
                let image = UIImage(data: data)
                else { return completion(.failure(.failedToUnwrapData)) }

            self?.cache.setObject(image, forKey: nsUrl)

            completion(.success(image))
        }.resume()
    }

    func clearPhotosSearchResults() {
        photos = []
    }
}
