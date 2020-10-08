//
//  UITableView+Rx.swift
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

public extension Reactive where Base: UITableView {
	
	var isEditing: Binder<Bool> {
		.init(self.base) {
			$0.isEditing = $1
		}
	}
	
	func isEditing(animated: Bool) -> Binder<Bool> {
		.init(self.base) {
			$0.setEditing($1, animated: animated)
		}
	}
	
	func reloadCells<S: Sequence, Cell: UITableViewCell, O: ObservableType>(_: Cell.Type, canEdit: Bool = true, canMove: Bool = true) -> (_ _: O) -> Disposable where
		O.Element == S,
		Cell: Reusable & Configurable,
		Cell.Model == S.Iterator.Element {
		{ source in
			source
				.map(Array.init) // sequence to array
				.map { SectionModel<(), Cell.Model>(model: (), items: $0) } // cell models to a section model
				.map { [$0] } // as single section array
				.bind(to: self.items(dataSource: RxTableViewSectionedReloadDataSource<SectionModel<(), Cell.Model>>(
										configureCell: { _, tableView, indexPath, item in
											let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
											cell.configure(with: item)
											return cell
										}, canEditRowAtIndexPath: {
											_, _ in canEdit
										}, canMoveRowAtIndexPath:  {
											_, _ in canMove
										})))
		}
	}
	
	func animatedCells<S: Sequence, Cell: UITableViewCell, O: ObservableType>(_: Cell.Type, canEdit: Bool = true, canMove: Bool = true) -> (_ _: O) -> Disposable where
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
				.bind(to: self.items(dataSource: RxTableViewSectionedAnimatedDataSource<SectionModel>(
										animationConfiguration: .init(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic),
										configureCell: { _, tableView, indexPath, wrappedItem in
											let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
											cell.configure(with: wrappedItem.item)
											return cell
										}, canEditRowAtIndexPath: { _, _ in
											canEdit
										}, canMoveRowAtIndexPath: { _, _ in
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
