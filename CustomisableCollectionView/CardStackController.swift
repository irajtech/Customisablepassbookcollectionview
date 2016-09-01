import UIKit

protocol CardStackControllerDataSource: class {
    func objects() -> [Int]
    func updateObjects(newCards: [Int])
}

protocol CardStackControllerDelegate: class {
    func cardStackControllerDidSelectItemAtIndexPath(cardStackController: CardStackController, indexPath: NSIndexPath)
}

enum CardState: Int {
    case Normal = 0
    case Selected = 1
    case Collapsed = 2
}

class CardStackController: UICollectionViewController, CardStackCellDelegate, CardStackLayoutDataSource {
    weak var dataSource: CardStackControllerDataSource? = nil
    weak var delegate: CardStackControllerDelegate? = nil

    var cards = [Int]()

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        let layout = CardStackLayout()
        layout.actualCellHeight = Double(UIScreen.mainScreen().bounds.height - 120.0)
        layout.visibleCellHeight = 60.0
        super.init(collectionViewLayout: layout)
        let nib = UINib(nibName: "CardStackCell", bundle: nil)
        self.collectionView?.registerNib(nib, forCellWithReuseIdentifier: "CardStackCellIdentifier")
        layout.dataSource = self
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let layout = CardStackLayout()
        self.init(collectionViewLayout: layout)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cards.append(CardState.Normal.rawValue)
        cards.append(CardState.Normal.rawValue)
        cards.append(CardState.Normal.rawValue)
        cards.append(CardState.Normal.rawValue)
        cards.append(CardState.Normal.rawValue)
        self.collectionView!.backgroundColor = UIColor.whiteColor()
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CardStackCell.Indentifier, forIndexPath: indexPath) as! CardStackCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.stackCell.backgroundColor = cell.getRandomColor()

        return cell
    }

    // MARK: CardStackCellDelegate

    func expandRows() {
        let count = self.cards.count
        var cards = [Int]()

        for index in 0..<count {
            cards.insert(CardState.Normal.rawValue, atIndex: index)
        }
        self.cards = cards
    }

    func collapseRows(selectedRow: Int) {
        let count = self.cards.count
        var cards = [Int]()

        for index in 0..<count {
            if index == selectedRow {
                cards.insert(CardState.Selected.rawValue, atIndex: index)
            } else {
                cards.insert(CardState.Collapsed.rawValue, atIndex: index)
            }
        }
        self.cards = cards
    }

    func cellDidPanAtIndexPath(cell: CardStackCell, indexPath: NSIndexPath?) {
        self.animateSelectionAtIndexPath(indexPath!)
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.animateSelectionAtIndexPath(indexPath)
        self.delegate?.cardStackControllerDidSelectItemAtIndexPath(self, indexPath: indexPath)
    }

    func animateSelectionAtIndexPath(indexPath: NSIndexPath) {
        self.collectionView?.performBatchUpdates({
            self.selectCardAtIndexPath(indexPath)
            }, completion: { finished in
            let layout = self.collectionView?.collectionViewLayout
            layout?.invalidateLayout()
        })
    }

    func selectCardAtIndexPath(indexPath: NSIndexPath) {
        let state = self.cardStateAtIndexPath(indexPath)
        switch state {
        case CardState.Normal.rawValue:
            self.collapseRows(indexPath.row)
        case CardState.Selected.rawValue, CardState.Collapsed.rawValue:
            self.expandRows()
        default: break
        }
    }

    // MARK: CardStackLayoutDataSource

    func cardStateAtIndexPath(indexPath: NSIndexPath) -> Int {
        let cards = self.cards
        let state = cards[indexPath.row]
        return state
    }
}

