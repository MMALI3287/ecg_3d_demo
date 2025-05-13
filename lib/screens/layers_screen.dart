import 'package:flutter/material.dart';

class LayersScreen extends StatefulWidget {
  const LayersScreen({Key? key}) : super(key: key);

  @override
  State<LayersScreen> createState() => _LayersScreenState();
}

class _LayersScreenState extends State<LayersScreen> {
  // Layer structure based on your model
  final Map<String, List<String>> electrodeGroups = {
    'Electrods Original': [
      'Electrods Original Green',
      'Electrods Original Red',
      'Electrods Original White',
    ],
    'Electrods Misplaces': [
      'Electrods Misplaces Green',
      'Electrods Misplaces Red',
      'Electrods Misplaces White',
    ],
    'Electrods Missing': [
      'Electrods Missing Green',
      'Electrods Missing Red',
      'Electrods Missing White',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electrode Layers'),
        backgroundColor: Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A11CB).withOpacity(0.3), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Explanation Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Electrode Layers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The 3D model contains different types of electrodes that can be toggled on or off. '
                      'Each electrode can be in one of three states:',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow('Original', 'Correct electrode placement'),
                    _buildInfoRow('Misplaces', 'Incorrect electrode placement'),
                    _buildInfoRow('Missing', 'Electrode that should be present but is not'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Electrode Groups
            ...electrodeGroups.entries.map((entry) => _buildElectrodeGroup(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: EdgeInsets.only(top: 5, right: 10),
            decoration: BoxDecoration(
              color: Color(0xFF6A11CB),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildElectrodeGroup(String groupName, List<String> electrodes) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          groupName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          ...electrodes.map((electrode) => ListTile(
            title: Text(electrode.replaceAll('Electrods ', '')),
            leading: Icon(
              _getIconForElectrode(electrode),
              color: _getColorForElectrode(electrode),
            ),
            dense: true,
          )),
        ],
      ),
    );
  }
  
  IconData _getIconForElectrode(String electrode) {
    if (electrode.toLowerCase().contains('green')) {
      return Icons.circle;
    } else if (electrode.toLowerCase().contains('red')) {
      return Icons.change_history;
    } else {
      return Icons.square;
    }
  }
  
  Color _getColorForElectrode(String electrode) {
    if (electrode.toLowerCase().contains('green')) {
      return Colors.green;
    } else if (electrode.toLowerCase().contains('red')) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }
}
