# !/bin/bash
# Script para controlar el servidor de 'Half-Life 2: Deahtmatch' de Scavenger S.A.

# Ruta hacia el script de 'srcds_run', para arrancar el servidor de HL2:DM.
RUTA_SRCDS="/home/dromero/juegos/hl2dm/srcds_run"
# Parámetros que se establecen al iniciar el servidor.
PARAMETROS="-game hl2mp +map dm_overwatch -maxplayers 16 -port 27020"

# Indica con un 1 si existe una sesión de tmux llamada 'scavenger', o 0 si no existe.
NUM_SESION=`(tmux ls | grep ^scavenger: | wc -l) 2> /dev/null`
# Indica con un 1 si existe una ventana llamada 'hl2dm' en la sesión de tmux 'scavenger', o 0 si no existe.
NUM_VENTANA=`(tmux lsw -t scavenger | grep hl2dm | wc -l) 2> /dev/null`

case "$1" in
	iniciar|inicio)
		echo "Iniciando servidor..."
		if [ "$NUM_SESION" = 0 ]
		then
			tmux new -ds scavenger -n hl2dm
			tmux send-keys -t scavenger:hl2dm "Enter" "$RUTA_SRCDS $PARAMETROS" "Enter"
		elif [ "$NUM_SESION" = 1 ] && [ "$NUM_VENTANA" = 0 ]
		then
			tmux neww -dn hl2dm
			tmux send-keys -t scavenger:hl2dm "Enter" "$RUTA_SRCDS $PARAMETROS" "Enter"
		else
			tmux send-keys -t scavenger:hl2dm "Enter" "$RUTA_SRCDS $PARAMETROS" "Enter"
		fi
		echo "Hecho."
		;;
	reiniciar|reinicio)
		echo "Reiniciando servidor..."
		if [ "$NUM_VENTANA" != 0 ]
		then
			tmux selectw -t scavenger:hl2dm
			tmux killw -t hl2dm
			echo "Servidor detenido. Por favor, espera mientras se vuelve a iniciar."
			sleep 5;
		fi
		echo "Iniciando servidor..."
		tmux new -ds scavenger -n hl2dm
		tmux send-keys -t scavenger:hl2dm "Enter" "$RUTA_SRCDS $PARAMETROS" "Enter"
		echo "Hecho."
		;;
	parar|detener)
		if [ "$NUM_VENTANA" = 0 ]
		then
			echo "El servidor de HL2:DM ya está parado."
		else
			echo "Deteniendo servidor..."
			tmux selectw -t scavenger:hl2dm
			tmux killw -t hl2dm
			echo "Se ha detenido el servidor de HL2:DM con éxito."
		fi
		;;
	consola|con)
		if [ "$NUM_VENTANA" = 0 ]
		then
			echo "No se puede acceder a la consola porque el servidor no está activo."
		else
			echo "Accediendo a la consola..."
			sleep 1;
			tmux selectw -t scavenger:hl2dm
			tmux attach -t scavenger
		fi
		;;
	estado)
		echo "Estado del servidor:"
		num_srcds_run=`ps -u dromero -o pid,ppid,cmd | grep "$RUTA_SRCDS $PARAMETROS" | grep -v grep | wc -l`
		pid_srcds_run=`ps -u dromero -o pid,ppid,cmd | grep "$RUTA_SRCDS $PARAMETROS" | grep -v grep | cut -f1 -d' '`
		num_srcds_linux=`(ps -u dromero -o pid,ppid,cmd --ppid "$PID_SRCDS_RUN" | grep "./srcds_linux $PARAMETROS" | grep -v grep | wc -l) 2> /dev/null`
		if [ "$num_srcds_linux" = 0 ]
		then
			echo "El servidor está parado."
		else
			echo "El servidor está en funcionamiento."
		fi
		;;
	*)
		echo "Uso: $0 {iniciar|reiniciar|parar|consola|estado}"
		;;
esac

exit 0
