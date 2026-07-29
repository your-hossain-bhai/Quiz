// Smooth scrolling for buttons
document.addEventListener('DOMContentLoaded',function(){
  const exploreBtn = document.getElementById('exploreBtn');
  const getStartedBtn = document.getElementById('getStartedBtn');
  const features = document.getElementById('features');
  const hero = document.getElementById('hero');

  if(exploreBtn){
    exploreBtn.addEventListener('click',()=>{
      features.scrollIntoView({behavior:'smooth',block:'start'});
    });
  }

  if(getStartedBtn){
    getStartedBtn.addEventListener('click',()=>{
      hero.scrollIntoView({behavior:'smooth',block:'start'});
    });
  }

  // Intersection Observer for reveal animations
  const animatedSelector = '.card[data-animate], .feature, .tech-card';
  const elements = Array.from(document.querySelectorAll(animatedSelector));

  if('IntersectionObserver' in window){
    try{
      const observer = new IntersectionObserver((entries)=>{
        entries.forEach(entry=>{
          if(entry.isIntersecting){
            entry.target.classList.add('in-view');
            observer.unobserve(entry.target);
          }
        });
      },{threshold:0.12});
      elements.forEach(el=>observer.observe(el));
    }catch(err){
      // fallback: reveal all
      elements.forEach(el=>el.classList.add('in-view'));
      console.warn('Observer error, revealing elements', err);
    }
  }else{
    // Fallback for older browsers: simply reveal after small delay
    setTimeout(()=>elements.forEach(el=>el.classList.add('in-view')),200);
  }

  // Micro-interaction: subtle parallax on hero mousemove
  const heroCard = document.querySelector('.hero-card');
  const heroSection = document.querySelector('.hero');
  if(heroSection && heroCard){
    heroSection.addEventListener('mousemove',e=>{
      const rect = heroSection.getBoundingClientRect();
      const x = (e.clientX - rect.left) / rect.width - 0.5;
      const y = (e.clientY - rect.top) / rect.height - 0.5;
      heroCard.style.transform = `translate3d(${x*8}px,${y*8}px,0)`;
    });
    heroSection.addEventListener('mouseleave',()=>{
      heroCard.style.transform = '';
    });
  }
});
