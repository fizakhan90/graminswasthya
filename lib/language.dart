class Language {
  final String name;
  final String languageCode;
  final String welcomeText;
  final String graminSwasthya;

  Language(this.name, this.languageCode, this.welcomeText, this.graminSwasthya);

  static List<Language> languageList() {
    return <Language>[
      Language("English", "en", "Welcome to our Chatbot", "Gramin Swasthya"),
      Language("हिंदी", "hi", "हमारे चैटबॉट में आपका स्वागत है", "ग्रामीण स्वास्थ्य"),
      //Language("தமிழ்", "ta", "எங்கள் chatbot க்கு வரவேற்கிறோம்", "கிராமப்புற சுகாதாரம்"),
      //Language("తెలుగు", "te", "మా చాట్‌బాట్‌కి స్వాగతం", "గ్రామీణ ఆరోగ్యం"),
      //Language("ಕನ್ನಡ", "kn", "ನಮ್ಮ ಚಾಟ್‌ಬಾಟ್‌ಗೆ ಸುಸ್ವಾಗತ", "ಗ್ರಾಮೀಣ ಆರೋಗ್ಯ"),
      //Language("മലയാളം", "ml", "ഞങ്ങളുടെ ചാറ്റ്ബോട്ടിലേക്ക് സ്വാഗതം", "ഗ്രാമീണ ആരോഗ്യം"),
      Language("বাংলা", "bn", "আমাদের চ্যাটবটে স্বাগতম", "গ্রামীণ স্বাস্থ্য"),
      Language("ગુજરાતી", "gu", "અમારા ચેટબોટમાં આપનું સ્વાગત છે", "ગ્રામીણ સ્વાસ્થ્ય"),
      //Language("ଓଡ଼ିଆ", "or", "ଆମର ଚାଟବଟରେ ଆପଣଙ୍କୁ ସ୍ୱାଗତ", "ଗ୍ରାମୀଣ ସ୍ୱାସ୍ଥ୍ୟ"),
      //Language("मराठी", "mr", "आमच्या चॅटबॉटमध्ये आपले स्वागत आहे", "ग्रामीण आरोग्य"),
    ];
  }
}