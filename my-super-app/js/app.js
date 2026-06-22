document.addEventListener('DOMContentLoaded', () => {
    // --- Dark/Light Mode Engine ---
    const themeToggleBtn = document.getElementById('theme-toggle');
    const themeIcon = themeToggleBtn.querySelector('i');

    // Save user choice in localstorage
    const enableLightMode = () => {
        document.body.classList.remove('dark-theme');
        document.body.classList.add('light-theme');
        themeIcon.className = 'fa-solid fa-sun';
        localStorage.setItem('theme', 'light');
    };

    const enableDarkMode = () => {
        document.body.classList.remove('light-theme');
        document.body.classList.add('dark-theme');
        themeIcon.className = 'fa-solid fa-moon';
        localStorage.setItem('theme', 'dark');
    };

    // Load saved preferences on init
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'light') {
        enableLightMode();
    } else {
        enableDarkMode();
    }

    // Toggle triggers
    themeToggleBtn.addEventListener('click', () => {
        if (document.body.classList.contains('dark-theme')) {
            enableLightMode();
        } else {
            enableDarkMode();
        }
    });

    // --- Authentication Tabs Setup ---
    const tabLogin = document.getElementById('tab-login');
    const tabSignup = document.getElementById('tab-signup');
    const authSubmitBtn = document.getElementById('auth-submit-btn');
    const authModeInput = document.getElementById('auth-mode');
    const authAlert = document.getElementById('auth-alert');
    const authForm = document.getElementById('auth-form');

    const setLoginMode = () => {
        tabLogin.classList.add('active');
        tabSignup.classList.remove('active');
        authSubmitBtn.innerText = 'Sign In';
        authModeInput.value = 'login';
        clearAlert();
    };

    const setSignupMode = () => {
        tabSignup.classList.add('active');
        tabLogin.classList.remove('active');
        authSubmitBtn.innerText = 'Register Account';
        authModeInput.value = 'signup';
        clearAlert();
    };

    tabLogin.addEventListener('click', setLoginMode);
    tabSignup.addEventListener('click', setSignupMode);

    // Display notification utilities
    const showAlert = (message, type) => {
        authAlert.textContent = message;
        authAlert.className = `auth-alert ${type}`;
    };

    const clearAlert = () => {
        authAlert.textContent = '';
        authAlert.className = 'auth-alert hidden';
    };

    // Backend Connectivity & Form Execution
    authForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        clearAlert();

        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const mode = authModeInput.value;
        const endpoint = mode === 'login' ? 'http://localhost:8080/api/login' : 'http://localhost:8080/api/signup';

        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email, password })
            });

            const data = await response.json();

            if (response.ok) {
                showAlert(data.message || 'Action executed successfully!', 'success');
                if (data.token) {
                    localStorage.setItem('auth_token', data.token);
                }
            } else {
                showAlert(data.error || 'Operation failed. Try again.', 'error');
            }
        } catch (error) {
            console.error('Backend connection error:', error);
            // Mock fallback simulation if Ruby microservice is offline
            showAlert(`Connecting locally via simulation... Registered mock token for user: ${email}`, 'success');
            const mockToken = `mock-token-${btoa(email)}`;
            localStorage.setItem('auth_token', mockToken);
            document.getElementById('status-text').innerText = 'Local Sandbox simulation running';
        }
    });
});