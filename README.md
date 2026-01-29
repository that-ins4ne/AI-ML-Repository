# AI-ML-Repository

A collection of AI/ML projects and DevOps tools for data science and server management.

## Projects

### 📊 Data Science & Machine Learning

1. **Analysing Survival on the Titanic** - Data analysis and predictive modeling on the famous Titanic dataset
2. **Netflix's Content Strategy** - Analysis of Netflix's content and viewing patterns
3. **Predicting Housing Market Trends with AI** - Machine learning model for housing market predictions

### 🔒 DevOps & Security

4. **[Linux Server Hardening](server-hardening/)** - Automated security configuration for production Linux servers
   - One-click server hardening script
   - Essential security measures (Firewall, SSH, Fail2ban, Auto-updates)
   - Complete documentation and configuration templates
   - Perfect for VPS and cloud server deployment
   
   **Quick Start:**
   ```bash
   cd server-hardening
   sudo ./harden-server.sh
   ```
   
   See the [Quick Start Guide](server-hardening/QUICKSTART.md) or [Full Documentation](server-hardening/README.md) for details.

## Repository Structure

```
AI-ML-Repository/
├── Analysing_Survival_on_the_Titanic.ipynb
├── Netflix's_Content_Strategy.ipynb
├── Predicting_Housing_Market_Trends_with_AI.ipynb
└── server-hardening/
    ├── README.md                  # Comprehensive documentation
    ├── QUICKSTART.md              # Quick start guide
    ├── harden-server.sh           # Main hardening script
    ├── check-security.sh          # Security status checker
    ├── create-user.sh             # User management helper
    └── configs/                   # Configuration templates
        ├── fail2ban-jail.local.example
        ├── sshd_config.example
        └── firewall-examples.md
```

## Getting Started

### For Data Science Projects
Open the Jupyter notebooks in your preferred environment (Jupyter Lab, Google Colab, etc.)

### For Server Hardening
1. Clone this repository on your Linux server
2. Navigate to the `server-hardening` directory
3. Follow the [Quick Start Guide](server-hardening/QUICKSTART.md)

## Contributing

Contributions are welcome! Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Share your experience

## License

This repository contains educational projects and tools. Use at your own discretion.