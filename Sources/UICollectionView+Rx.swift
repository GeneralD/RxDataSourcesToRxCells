//
//  UICollectionView+Rx.swift
//  AnyMediaPicker
//
//  Created by Yumenosuke Koukata on 2020/09/21.
//  Copyright © 2020 ZYXW. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxCells
import RxDataSources
import Reusable

public extension Reactive where Base: UICollectionView {
	
	@available(iOS 14.0, *)
	var isEditing: Binder<Bool> {
		.init(self.base) {
			$0.isEditing = $1
		}
	}
	
	func reloadCells<S: Sequence, Cell: UICollectionViewCell, O: ObservableType>(_: Cell.Type, canMove: Bool = true) -> (_ _: O) -> Disposable where
		O.Element == S,
		Cell: Reusable & Configurable,
		Cell.Model == S.Iterator.Element {
		{ source in
			source
				.map(Array.init) // sequence to array
				.map { SectionModel<(), Cell.Model>(model: (), items: $0) } // cell models to a section model
				.map { [$0] } // as single section array
				.bind(to: self.items(dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<(), Cell.Model>>(
										configureCell: { _, collectionView, indexPath, item in
											let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
											cell.configure(with: item)
											return cell
										}, canMoveItemAtIndexPath: { _, _ in
											canMove
										})))
		}
	}
	
	func animatedCells<S: Sequence, Cell: UICollectionViewCell, O: ObservableType>(_: Cell.Type, canMove: Bool = true) -> (_ _: O) -> Disposable where
		O.Element == S,
		Cell: Reusable & Configurable,
		Cell.Model == S.Iterator.Element,
		S.Iterator.Element: Hashable {
		typealias SectionModel = AnimatableSectionModel<DummyIdentifiable, IdentifiableItemWrapper<Cell.Model>>
		return { source in
			source
				.map { $0.map(IdentifiableItemWrapper<Cell.Model>.init(item: )) } // wrap every element with identifiable
				.map(Array.init) // sequence to array
				.map { SectionModel(model: .init(), items: $0) } // cell models to a section model
				.map { [$0] } // as single section array
				.bind(to: self.items(dataSource: RxCollectionViewSectionedAnimatedDataSource<SectionModel>(
										animationConfiguration: .init(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic),
										configureCell: { _, collectionView, indexPath, wrappedItem in
											let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
											cell.configure(with: wrappedItem.item)
											return cell
										}, canMoveItemAtIndexPath: { _, _ in
											canMove
										})))
		}
	}
}

private struct DummyIdentifiable: IdentifiableType {
	
	let identity = 0
}

private struct IdentifiableItemWrapper<Item>: IdentifiableType, Equatable where Item: Hashable {
	
	typealias Identity = Item
	
	let item: Item
	
	var identity: Item {
		return item
	}
}
