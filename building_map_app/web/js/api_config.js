// Google Maps API 설정
const API_CONFIG = {
    // Google Maps API 키 (실제 배포 시에는 환경변수 사용 권장)
    GOOGLE_MAPS_API_KEY: 'AIzaSyDQK8SOOSJsDH8H7HuPbwHNv72MHE_ZpsA',

    // API 키 유효성 검사
    isApiKeyValid: function() {
        return this.GOOGLE_MAPS_API_KEY &&
               this.GOOGLE_MAPS_API_KEY !== 'YOUR_API_KEY_HERE' &&
               this.GOOGLE_MAPS_API_KEY.length > 0;
    }
};

// 전역으로 내보내기
window.API_CONFIG = API_CONFIG;