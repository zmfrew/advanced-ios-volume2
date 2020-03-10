import UIKit

final class PlayerView: UIView {
    weak var controller: PlayViewController?
    var picker = UIPickerView()
    var select = UIButton(type: .custom)
    var sortedSongs = [Song]()
    
    init(color: UIColor, songs: [Song], delegate: PlayViewController) {
        super.init(frame: .zero)
        
        controller = delegate
        select.backgroundColor = color
        sortedSongs = songs.sorted()
        backgroundColor = .white
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        select.translatesAutoresizingMaskIntoConstraints = false
        addSubview(picker)
        addSubview(select)
        
        picker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        picker.topAnchor.constraint(equalTo: topAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: select.topAnchor).isActive = true
        
        select.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        select.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        select.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        select.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        select.setTitle("Select Song", for: .normal)
        select.setTitleColor(.white, for: .normal)
        select.showsTouchWhenHighlighted = true
        select.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)
        
        picker.dataSource = self
        picker.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func selectTapped() {
        let selection = sortedSongs[picker.selectedRow(inComponent: 0)]
        controller?.selectTapped(player: select.backgroundColor!, answer: selection.attributes.name)
    }
}

extension PlayerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        sortedSongs.count
    }
}

extension PlayerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        sortedSongs[row].attributes.name
    }
}
