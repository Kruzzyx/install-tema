cd /var/www/pterodactyl
cat <<'EOF' >> resources/scripts/neobrutalism.css

/* Latar belakang bintang jatuh (falling stars) */
.nb-sky-bg {
  position: fixed;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  overflow: hidden;
}

.nb-star-streak {
  position: absolute;
  top: -80px;
  width: 2px;
  height: 90px;
  background: linear-gradient(180deg, rgba(250, 204, 21, 0), rgba(56, 189, 248, 0.9), rgba(255, 255, 255, 1));
  box-shadow: 0 0 10px rgba(56, 189, 248, 0.8), 0 0 18px rgba(168, 85, 247, 0.6);
  transform: rotate(35deg);
  opacity: 0;
  animation: nb-falling-star linear infinite;
}

.nb-star-streak:nth-child(1) { left: 10%; animation-duration: 3.4s; animation-delay: 0.2s; }
.nb-star-streak:nth-child(2) { left: 26%; animation-duration: 4.2s; animation-delay: 1.4s; height: 70px; }
.nb-star-streak:nth-child(3) { left: 44%; animation-duration: 3.1s; animation-delay: 0.8s; }
.nb-star-streak:nth-child(4) { left: 62%; animation-duration: 4.6s; animation-delay: 2.1s; height: 110px; }
.nb-star-streak:nth-child(5) { left: 78%; animation-duration: 3.7s; animation-delay: 1.1s; }
.nb-star-streak:nth-child(6) { left: 91%; animation-duration: 4.0s; animation-delay: 2.7s; height: 75px; }

@keyframes nb-falling-star {
  0% {
    transform: translate3d(0, -120px, 0) rotate(35deg);
    opacity: 0;
  }
  12% {
    opacity: 1;
  }
  85% {
    opacity: 0.9;
  }
  100% {
    transform: translate3d(-240px, 110vh, 0) rotate(35deg);
    opacity: 0;
  }
}

#app > div, main, .wrapper {
  position: relative;
  z-index: 1;
}
EOF
