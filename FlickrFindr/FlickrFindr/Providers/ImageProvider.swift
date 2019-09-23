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

    let cache = NSCache<NSURL, UIImage>()

    var photos = [Photo]()

    // Photo search url format
    // https://api.flickr.com/services/rest?method=flickr.photos.search&api_key=1508443e49213ff84d566777dc211f2a&text=dog&format=json&per_page=25

    func fetchPhotos(for searchTerm: String, completion: @escaping(Result<Bool,ImageProviderError>) -> Void) {

        let parameters = [
            "method":"flickr.photos.search",
            "api_key":apiKey,
            "format":"json",
            "nojsoncallback":"1",
            "per_page":"25",
            "text":searchTerm
        ]
        let queryItems = parameters.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems

        guard let requestURL = urlComponents?.url else { return completion(.failure(.failedToConstructURL)) }

        URLSession.shared.dataTask(with: requestURL) { [weak self] data, response, error in
            // Handle this error better
            if let error = error {
                completion(.failure(.networkError(error)))
            }
            guard let data = data else { return completion(.failure(.failedToUnwrapData)) }

            let decoder = JSONDecoder()
            do {
                self?.photos = try decoder.decode(TopLevelObject.self, from: data).photosDictionary.photos
                completion(.success(true))
            } catch {
                completion(.failure(.failedToDecodeObject(error)))
            }

        }.resume()
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
            // Handle error
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

}
