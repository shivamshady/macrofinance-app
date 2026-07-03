/// MacroFinance — Regulatory Constants
/// RBI Digital Lending Directions 2025 compliance text
class RegulatoryConstants {
  RegulatoryConstants._();

  // ── NBFC Partner Info ──
  static const String nbfcName = 'MacroFinance Capital Ltd.';
  static const String nbfcRegistrationNumber = 'N-XX.XXXXX';
  static const String nbfcRegisteredWith = 'Reserve Bank of India (RBI)';
  static const String nbfcCategory = 'NBFC-ICC (Investment and Credit Company)';

  // ── Grievance Redressal ──
  static const String nodalOfficerName = 'Grievance Redressal Officer';
  static const String nodalOfficerEmail = 'grievance@macrofinance.in';
  static const String nodalOfficerPhone = '+91-XXXXXXXXXX';
  static const String rbiCmsPortal = 'https://cms.rbi.org.in';
  static const String rbiDlaDirectory = 'https://rbi.org.in/Scripts/PublicationsView.aspx?id=21aboretconfirm';
  static const int grievanceResolutionDays = 30;

  // ── Disclaimers ──
  static const String loanDisclaimer =
      'Loans are disbursed by $nbfcName, registered with the Reserve Bank of India '
      '(Registration No: $nbfcRegistrationNumber). All loans are subject to credit '
      'assessment and approval. The interest rate, processing fee, and other charges '
      'are determined based on the borrower\'s credit profile.';

  static const String kfsDisclaimer =
      'This Key Fact Statement (KFS) is provided as per the RBI Digital Lending '
      'Directions, 2025. It contains the essential terms and costs associated with '
      'your loan. Please read all terms carefully before accepting the loan offer.';

  static const String dataConsentText =
      'I hereby provide my explicit consent for MacroFinance and its lending partner '
      '$nbfcName to collect, process, and store my personal data including identity '
      'documents, financial information, and credit history for the purpose of loan '
      'processing, credit assessment, and regulatory compliance. I understand that:\n\n'
      '• My data will be stored on servers located within India.\n'
      '• I can withdraw my consent at any time.\n'
      '• My data will not be shared with unauthorized third parties.\n'
      '• I have the right to request deletion of my data.\n'
      '• No access to my phone contacts, call logs, or media files will be requested.';

  static const String termsOfService =
      'By using MacroFinance, you agree to our Terms of Service and Privacy Policy. '
      'This platform operates in compliance with the Reserve Bank of India\'s Digital '
      'Lending Directions, 2025, and applicable Indian laws including the Digital '
      'Personal Data Protection Act, 2023.';

  static const String coolingOffPeriod =
      'As per RBI guidelines, you have a look-up/cooling-off period within which you '
      'may exit the loan agreement by repaying the principal and proportionate APR '
      'without any penalty. The cooling-off period for this loan is specified in the '
      'Key Fact Statement.';

  static const String investmentDisclaimer =
      'Investments in loan portfolios carry inherent risks including the risk of '
      'borrower default. Returns are not guaranteed. Past performance does not '
      'indicate future results. Please assess your risk appetite before investing.';

  // ── KFS Template Labels ──
  static const String kfsLabelApr = 'Annual Percentage Rate (APR)';
  static const String kfsLabelPrincipal = 'Loan Principal Amount';
  static const String kfsLabelTotalInterest = 'Total Interest Payable';
  static const String kfsLabelTotalRepayment = 'Total Amount Repayable';
  static const String kfsLabelProcessingFee = 'Processing Fee';
  static const String kfsLabelInsurance = 'Insurance Charges (if applicable)';
  static const String kfsLabelTenure = 'Loan Tenure';
  static const String kfsLabelEmi = 'Equated Monthly Installment (EMI)';
  static const String kfsLabelPenalty = 'Penal Charges on Late Payment';
  static const String kfsLabelForeclosure = 'Foreclosure/Prepayment Charges';
  static const String kfsLabelCoolingOff = 'Look-up/Cooling-off Period';
  static const String kfsLabelGrievance = 'Grievance Redressal Officer';
  static const String kfsLabelLender = 'Name of the Lender (Regulated Entity)';

  // ── Data Collection Policy ──
  static const List<String> permittedDataCollection = [
    'Full Name',
    'Date of Birth',
    'PAN Number',
    'Aadhaar Number (masked — last 4 digits only)',
    'Mobile Number',
    'Email Address',
    'Bank Account Details',
    'Employment/Income Information',
    'Credit Score (via authorized bureau)',
    'Selfie/Photo (for liveness verification)',
    'Device ID and IP Address (for fraud prevention)',
  ];

  static const List<String> prohibitedDataAccess = [
    'Phone Contacts',
    'Call Logs',
    'SMS Messages',
    'Media Files (Photos/Videos)',
    'Social Media Accounts',
    'Browsing History',
  ];
}
