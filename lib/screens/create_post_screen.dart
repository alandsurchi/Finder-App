import 'package:flutter/material.dart';
import 'package:finder/widgets/custom_text_field.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  bool _isLostItem = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0DEE8), // Light background from design
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2045),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Post',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Report a lost or found item',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'I want to report',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2045)),
            ),
            const SizedBox(height: 15),
            // Toggle Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLostItem = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isLostItem ? const Color(0xFFFF4C4C) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          if (!_isLostItem)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, size: 12, color: _isLostItem ? Colors.white : const Color(0xFFFF4C4C)),
                          const SizedBox(width: 8),
                          Text(
                            'Lost Item',
                            style: TextStyle(
                              color: _isLostItem ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLostItem = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isLostItem ? const Color(0xFF4E9F3D) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          if (_isLostItem)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, size: 12, color: !_isLostItem ? Colors.white : const Color(0xFF4E9F3D)),
                          const SizedBox(width: 8),
                          Text(
                            'Found Item',
                            style: TextStyle(
                              color: !_isLostItem ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            
            // Photos
            const Text(
              'Photos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2045)),
            ),
            const SizedBox(height: 10),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt_outlined, color: Colors.purple, size: 30),
                  SizedBox(height: 5),
                  Text('Add Photo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Upload up to 6 photos • 0/6 added',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            
            const SizedBox(height: 25),
            
            // Item Title
            _buildLabel('Item Title'),
            _buildTextField('e.g., Black Leather Wallet'),
            
            const SizedBox(height: 20),
            
            // Description
            _buildLabel('Description'),
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.transparent),
              ),
              child: const TextField(
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Provide detailed description of the item...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Category
            _buildLabel('Category'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select category', style: TextStyle(color: Colors.grey)),
                  items: <String>['Electronics', 'Wallet', 'Keys', 'Jewelry', 'Pets', 'Other']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Location
            _buildLabel('Location'),
            _buildTextField('Where was it lost/found?', icon: Icons.location_on_outlined),
            
            const SizedBox(height: 20),
            
            // Date
            _buildLabel('Date Lost'),
            _buildTextField('', icon: Icons.calendar_today_outlined),
            
            const SizedBox(height: 20),
            
            // Reward
            if (_isLostItem) ...[
              _buildLabel('Reward (Optional)'),
              _buildTextField('e.g., \$50'),
              const SizedBox(height: 30),
            ],
            
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2045)),
            ),
            const Text(
              'How can people reach you?',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            
            const SizedBox(height: 15),
            
            _buildLabel('Email Address'),
            _buildTextField('your.email@example.com', icon: Icons.email_outlined),
            
            const SizedBox(height: 20),
            
            _buildLabel('Phone Number'),
            _buildTextField('+1 (555) 000-0000', icon: Icons.phone_outlined),
            
            const SizedBox(height: 40),
            
            // Post Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement post logic
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5334F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF5334F5).withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Post Item',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 5),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F2045),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          icon: icon != null ? Icon(icon, color: const Color(0xFF5334F5), size: 20) : null,
        ),
      ),
    );
  }
}
