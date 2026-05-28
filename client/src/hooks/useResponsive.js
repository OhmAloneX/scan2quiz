import { useEffect, useState } from 'react'

export default function useResponsive() {
  const [width, setWidth] = useState(() =>
    typeof window !== 'undefined' ? window.innerWidth : 1200
  )

  useEffect(() => {
    function onResize() {
      setWidth(window.innerWidth)
    }

    window.addEventListener('resize', onResize)
    return () => window.removeEventListener('resize', onResize)
  }, [])

  // breakpoints (tuned for this app)
  const isMobile = width < 640
  const isTablet = width >= 640 && width < 1024
  const isDesktop = width >= 1024

  return {
    width,
    isMobile,
    isTablet,
    isDesktop,
  }
}

