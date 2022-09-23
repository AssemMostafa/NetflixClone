//
//  DataPersistenceManger.swift
//  NetflixClone
//
//  Created by Assem on 22/09/2022.
//

import UIKit
import CoreData

class DataPersistenceManger {

    enum DatabaseError: Error {
        case faildToSaveData
        case faildToFetchData
        case faildToDeleteData

    }
    static let shared = DataPersistenceManger()

    // MARK: Save Movie
    func downloadTitle(with model: Title, completion: @escaping (Result<Void, Error>) -> Void) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let item = TitleItem(context: context)

        item.original_title = model.original_title
        item.id = Int64(model.id)
        item.original_name = model.original_name
        item.overview = model.overview
        item.poster_path = model.poster_path
        item.media_type = model.media_type
        item.release_date = model.release_date
        item.vote_count = item.vote_count
        item.vote_average = item.vote_average

        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.faildToSaveData))
        }
    }

    // MARK: Load Movie
    func fetchingTitlesFromDataBase(completion: @escaping (Result<[TitleItem], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<TitleItem>
        request = TitleItem.fetchRequest()
        do {
           let titles =  try context.fetch(request)
            completion(.success(titles))
        } catch {
            print(error.localizedDescription)
            completion(.failure(DatabaseError.faildToFetchData))
        }
    }

    // MARK: Delete Movie
    func deleteTitle(with model: TitleItem, completion: @escaping (Result<Void, Error>) -> Void) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        context.delete(model)
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.faildToDeleteData))
        }

    }
}
