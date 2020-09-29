
Процедура ПриЗаписи(Отказ)
	
	Для каждого Движение Из Движения.Проводки Цикл
	
		  Движение.Период = Дата;
	
	  КонецЦикла;
	  
	  Если ПометкаУдаления Тогда
		 
		 ОбщийМодульНаСервере.ИзменитьАктивностьДвижений(Ссылка, Ложь);
		 
	 КонецЕсли;
	  
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	НаборЗаписиОбъектаКопирования = ОбъектКопирования.Движения.Проводки;
	
	НаборЗаписиОбъектаКопирования.Прочитать();
	
	//Выгрузим Набор записей объекта копирования в таблицу занчений
	
	ТЗ = НаборЗаписиОбъектаКопирования.Выгрузить();
	
	//Загрузим таблицу значений в набор записей связанный с новым объектом
	
	Движения.Проводки.Загрузить(ТЗ);
	
КонецПроцедуры
