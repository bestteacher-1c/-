Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	
	//проверка вынесена в подписку на события
	
	//Если ПолучитьФункциональнуюОпцию("УчетПоПодразделениям"
	//	, Новый Структура("ПФО_Организация", Организация)) = Ложь Тогда
	//
	//	  Индекс = ПроверяемыеРеквизиты.Найти("Подразделение");
	//		ПроверяемыеРеквизиты.Удалить(Индекс);
	//		
	//
	//КонецЕсли;                      
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

	Если ВидОперации = Перечисления.ВидыОперацийПродажиТоваров.Продажа Тогда
	
		ПродажаТовара(Отказ, Режим);
		
	Иначе
		
		ВозвратТовараВладельцу(Отказ, Режим);
	
	КонецЕсли;
	
	
	Если Отказ = Ложь Тогда
		
		Движения.Проводки.Записывать = Истина;
		
	КонецЕсли; 
	
КонецПроцедуры

Процедура ПродажаТовара(Отказ, Режим)
	
	//В учебных целях (для упрощения) делаем допущение, что складской учет ведется.
	
	
	//--БЛОКИРОВКА
	#Область Блокировка
	
	Блокировка = Новый БлокировкаДанных;
	
	ЧтоБлокируем = Блокировка.Добавить("РегистрБухгалтерии.Проводки");
	ЧтоБлокируем.Режим = РежимБлокировкиДанных.Исключительный;   //Можно не писать. Этот режим работает "по умолчанию".
	
	ЧтоБлокируем.УстановитьЗначение("Организация", Организация);
	ЧтоБлокируем.УстановитьЗначение("Подразделение", Подразделение);
	
	
	МассивТипов = Новый Массив;
	МассивТипов.Добавить("СправочникСсылка.Номенклатура");
	МассивТипов.Добавить("СправочникСсылка.Склады");
	
	
	ТЗ = Новый ТаблицаЗначений;
	ТЗ.Колонки.Добавить("Счет",Новый ОписаниеТипов("ПланСчетовСсылка.Счета"));
	ТЗ.Колонки.Добавить("Субконто_1",Новый ОписаниеТипов(МассивТипов));
	ТЗ.Колонки.Добавить("Субконто_2",Новый ОписаниеТипов(МассивТипов));
	
	
	Для каждого ТекСтрока Из Товары Цикл
		
		НоваяСтрокаТЗ = ТЗ.Добавить();
		НоваяСтрокаТЗ.Счет = ТекСтрока.СчетУчета;
		
		Если ТекСтрока.СчетУчета.ВидыСубконто.Получить(0).ВидСубконто 
			= ПланыВидовХарактеристик.ВидыСубконто.Номенклатура Тогда
			
			НоваяСтрокаТЗ.Субконто_1 = ТекСтрока.Номенклатура;
			НоваяСтрокаТЗ.Субконто_2 = Склад;
			
		Иначе
			
			НоваяСтрокаТЗ.Субконто_1 = Склад;
			НоваяСтрокаТЗ.Субконто_2 = ТекСтрока.Номенклатура;
			
		КонецЕсли;
		
	КонецЦикла;
	
	ЧтоБлокируем.ИсточникДанных = ТЗ;
	ЧтоБлокируем.ИспользоватьИзИсточникаДанных("Счет","Счет");
	ЧтоБлокируем.ИспользоватьИзИсточникаДанных("Субконто1","Субконто_1");
	ЧтоБлокируем.ИспользоватьИзИсточникаДанных("Субконто2","Субконто_2");
	
	
	Блокировка.Заблокировать();
	
	#КонецОбласти 	
	
	//--ОЧИСТКА ДВИЖЕНИЙ ЭТОГО ДОКУМЕНТА В БАЗЕ ДАННЫХ
	
	Движения.Проводки.Записывать = Истина;
	Движения.Записать();
	
	// ---  ЗАПРОС
	
	
	ПорядокСубконто = Новый Массив;
	ПорядокСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
	ПорядокСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Склады);
	
	
	Запрос = Новый Запрос;
	
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Период", МоментВремени());
	Запрос.УстановитьПараметр("ПорядокСубконто", ПорядокСубконто);
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Подразделение", Подразделение);
	Запрос.УстановитьПараметр("Склад", Склад);
	
	Запрос.Текст = "ВЫБРАТЬ
|	ПродажаТоваровТовары.Номенклатура,
|	СУММА(ПродажаТоваровТовары.Количество) КАК Количество,
|	СУММА(ПродажаТоваровТовары.Сумма) КАК Сумма,
|	ПродажаТоваровТовары.СчетУчета
|ПОМЕСТИТЬ ВТТоварыДокумента
|ИЗ
|	Документ.ПродажаТоваров.Товары КАК ПродажаТоваровТовары
|ГДЕ
|	ПродажаТоваровТовары.Ссылка = &Ссылка
|
|СГРУППИРОВАТЬ ПО
|	ПродажаТоваровТовары.Номенклатура,
|	ПродажаТоваровТовары.СчетУчета
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	ПроводкиОстатки.Счет,
|	ПроводкиОстатки.Субконто1,
|	ПроводкиОстатки.КоличествоОстатокДт
|ПОМЕСТИТЬ ВТОстаткиСклад
|ИЗ
|	РегистрБухгалтерии.Проводки.Остатки(
|			&Период,
|			Счет В
|				(ВЫБРАТЬ
|					ВТТоварыДокумента.СчетУчета
|				ИЗ
|					ВТТоварыДокумента КАК ВТТоварыДокумента),
|			&ПорядокСубконто,
|			Организация = &Организация
|				И Подразделение = &Подразделение
|				И Субконто1 В
|					(ВЫБРАТЬ
|						ВТТоварыДокумента.Номенклатура
|					ИЗ
|						ВТТоварыДокумента КАК ВТТоварыДокумента)
|				И Субконто2 = &Склад) КАК ПроводкиОстатки
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	ПроводкиОстатки.Счет,
|	ПроводкиОстатки.Субконто1,
|	ПроводкиОстатки.КоличествоОстатокДт,
|	ПроводкиОстатки.СуммаОстатокДт
|ПОМЕСТИТЬ ВТОстаткиВсе
|ИЗ
|	РегистрБухгалтерии.Проводки.Остатки(
|			&Период,
|			Счет В
|				(ВЫБРАТЬ
|					ВТТоварыДокумента.СчетУчета
|				ИЗ
|					ВТТоварыДокумента КАК ВТТоварыДокумента),
|			&ПорядокСубконто,
|			Организация = &Организация
|				И Подразделение = &Подразделение
|				И Субконто1 В
|					(ВЫБРАТЬ
|						ВТТоварыДокумента.Номенклатура
|					ИЗ
|						ВТТоварыДокумента КАК ВТТоварыДокумента)) КАК ПроводкиОстатки
|;
|
|////////////////////////////////////////////////////////////////////////////////
|ВЫБРАТЬ
|	ВТТоварыДокумента.Номенклатура,
|	ВТТоварыДокумента.Количество,
|	ВТТоварыДокумента.Сумма,
|	ВТТоварыДокумента.СчетУчета,
|	ЕСТЬNULL(ВТОстаткиСклад.КоличествоОстатокДт, 0) КАК КоличествоОстатокДт,
|	ВЫБОР
|		КОГДА ВТОстаткиВсе.КоличествоОстатокДт ЕСТЬ NULL
|			ТОГДА 0
|		КОГДА ВТОстаткиВсе.КоличествоОстатокДт = 0
|			ТОГДА 0
|		КОГДА ВТОстаткиВсе.КоличествоОстатокДт = ВТТоварыДокумента.Количество
|			ТОГДА ВТОстаткиВсе.СуммаОстатокДт
|		ИНАЧЕ ВТОстаткиВсе.СуммаОстатокДт / ВТОстаткиВсе.КоличествоОстатокДт * ВТТоварыДокумента.Количество
|	КОНЕЦ КАК Себестоимость
|ИЗ
|	ВТТоварыДокумента КАК ВТТоварыДокумента
|		ЛЕВОЕ СОЕДИНЕНИЕ ВТОстаткиСклад КАК ВТОстаткиСклад
|		ПО ВТТоварыДокумента.СчетУчета = ВТОстаткиСклад.Счет
|			И ВТТоварыДокумента.Номенклатура = ВТОстаткиСклад.Субконто1
|		ЛЕВОЕ СОЕДИНЕНИЕ ВТОстаткиВсе КАК ВТОстаткиВсе
|		ПО ВТТоварыДокумента.СчетУчета = ВТОстаткиВсе.Счет
|			И ВТТоварыДокумента.Номенклатура = ВТОстаткиВсе.Субконто1";
	
	
	Результат = Запрос.Выполнить();
	
	//--ВЫБОРКА ИЗ РЕЗУЛЬТАТА ЗАПРОСА
	
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		//--ПРОВЕРКА НАЛИЧИЯ УЧТЕННОГО ТМЦ ПО СЧЕТУ НА СКЛАДЕ
		
		Нехватка = Выборка.Количество - Выборка.КоличествоОстатокДт;
		
		Если Нехватка > 0 Тогда
			
			Отказ = Истина;
			
			Сообщение = Новый СообщениеПользователю;
			
			Сообщение.Текст = "Для проведения по данным бухгалтерского учета по счету "
			+ Выборка.СчетУчета + " не хватает номенклатуры """
			+ Выборка.Номенклатура + """. Нехватка составляет " + Нехватка + " ед.";
			
			Сообщение.Сообщить();
			
		КонецЕсли; 
		
		//--Формируем движения в регистре бухгелтрии
		
		Если Отказ = Ложь Тогда
			
			//=========================================================================
			//-- ПРОВОДКА = ДЕБЕТ (90) РАСХОДЫ -  КРЕДИТ СЧЕТ УЧЕТА ТМЦ (10, 41.1, 41.2) - СУММА СЕБЕСТОИМОСТИ 
			
			Движение = Движения.Проводки.Добавить();
			
			Движение.Период = Дата;
			Движение.СодержаниеПроводки = "Себестоимость продажи";
			Движение.Организация = Организация;
			Движение.Сумма = Выборка.Себестоимость;
			
			
			Движение.СчетДт = ПланыСчетов.Счета.РасходыДоходы;
			Бухгалтерия.ЗаполнитьПодразделениеСтороныПроводки(Движение, Подразделение, "Дт");
			
			
			
			Движение.СчетКт = Выборка.СчетУчета;
			
			Бухгалтерия.ЗаполнитьПодразделениеСтороныПроводки(Движение, Подразделение, "Кт");
			Бухгалтерия.ЗаполнитьКоличествоСтороныПроводки(Движение, Выборка.Количество, "Кт");
			
			Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение, "Номенклатура", Выборка.Номенклатура, "Кт");
			Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение, "Склады", Склад, "Кт");
			Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение, "Контрагенты", Контрагент, "Кт");
			
			
			//=========================================================================
			//-- ПРОВОДКА = ДЕБЕТ (62.1) РАСЧЕТЫ С ПОКУПАТЕЛЕМ - ТМЦ КРЕДИТ (90) ДОХОДЫ
			
			
			Движение = Движения.Проводки.Добавить();
			
			Движение.Период = Дата;
			Движение.СодержаниеПроводки = "Выручка от продажи";
			Движение.Организация = Организация;
			Движение.Сумма = Выборка.Сумма; 
			
			Движение.СчетДт = ПланыСчетов.Счета.ПокупателямОтгрузили;
			
			Бухгалтерия.ЗаполнитьПодразделениеСтороныПроводки(Движение, Подразделение, "Дт");
			
			Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение, "Контрагенты", Контрагент, "Дт");
			Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение, "Договоры", Договор, "Дт");
			
			Бухгалтерия.ЗаполнитьВалютуСтороныПроводки(Движение,Валюта,Выборка.Сумма,"Дт");
			
			Движение.СчетКт = ПланыСчетов.Счета.РасходыДоходы;
			
			Бухгалтерия.ЗаполнитьПодразделениеСтороныПроводки(Движение, Подразделение, "Кт");
			
			//? Может пригодиться
			Бухгалтерия.ЗаполнитьСубконтоСтороныПроводки(Движение, "Номенклатура", Выборка.Номенклатура, "Кт");
			
			
		КонецЕсли; 
		
	КонецЦикла;
	
	
	
КонецПроцедуры

Процедура ВозвратТовараВладельцу(Отказ, Режим)

	//Контрольная работа...
	
КонецПроцедуры

