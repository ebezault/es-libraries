{unless isset="$user"}
<div class="login-box">
	<div class="description">
	The magic link, to sign in, was sent to your inbox.
	</div>
	<div>
		<form name="cms_magic_link_auth" action="{$site_url/}account/auth/roc-magic-login" method="POST">
			{unless isempty="$site_destination"}<input type="hidden" name="destination" value="{htmlentities}{$site_destination/}{/htmlentities}">{/unless}
			<input type="hidden" name="username" id="username" required value="{htmlentities}{$username/}{/htmlentities}">

			<br/>
			<br/>

			<input id="resendLink" class="link disabled" type="submit" value="Resend a magic link ..."></input>
        	<span id="countdown" class="countdown" style="font-size: 80%; color: #555;" >(Wait <span id="timeLeft">30</span> seconds)</span>

		</form>
	</div>

{literal}    
    <script>
        let timeLeft = 30;
        const link = document.getElementById('resendLink');
        const countdownDiv = document.getElementById('countdown');
        const timeLeftSpan = document.getElementById('timeLeft');

        link.style.color = '#777';
        link.style.pointerEvents = 'none';
        link.style.cursor = 'not-allowed';
        
        // Prevent click events while disabled
        link.addEventListener('click', function(e) {
            if (link.classList.contains('disabled')) {
                e.preventDefault();
                return false;
            }
        });
        
        // Countdown timer
        const timer = setInterval(function() {
            timeLeft--;
            timeLeftSpan.textContent = timeLeft;
            
            if (timeLeft <= 0) {
                // Enable the link
                link.style.color = 'blue';
                link.style.pointerEvents = 'auto';
                link.style.cursor = 'pointer';                
                link.classList.remove('disabled');
                link.classList.add('enabled');                
                
                // Hide countdown
                countdownDiv.style.display = 'none';
                
                // Clear the timer
                clearInterval(timer);
            }
        }, 1000);
    </script>
{/literal}    
	{if isset="$error"}<div class="error">{$error/}</div>{/if}
</div>
{/unless}
