--极北之地
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--卡组检索
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--不能除外    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.rmlimit)
	c:RegisterEffect(e2)
	--等级改变
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)    
end
function s.thfilter(c)
	return aux.IsCodeListed(c,id) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.confilter(c)
	return c:IsFaceup() and (aux.IsCodeListed(c,id) or c:IsType(TYPE_SYNCHRO))
end
function s.spfilter(c,e,tp)
	return aux.IsCodeListed(c,id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    	and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)            	        	
	if (b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
    	if b2 and (not b1 or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
    		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
    	else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
			local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if tc then
        		if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then        
					Duel.SendtoHand(tc,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,tc)
           		else
                	Duel.SendtoGrave(tc,REASON_EFFECT)
                end
            end
        end
    end
end
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsAttribute(ATTRIBUTE_WATER) and rp==1-tp
end
function s.lvfilter(c)
	return aux.IsCodeListed(c,id) and c:IsFaceup() and c:IsLevelAbove(1)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		local op=aux.SelectFromOptions(tp,
			{tc:IsLevelAbove(1),aux.Stringid(id,4),1},
			{tc:IsLevelAbove(2),aux.Stringid(id,5),2})
        local t={}
        for i=1,3 do
			if op==2 then
            	if tc:GetLevel()-i>0 then
            		table.insert(t,i)
                end
            elseif op==1 then
            	table.insert(t,i)
            end        
		end
        if #t==0 then return end
		local lv=Duel.AnnounceNumber(tp,table.unpack(t))        
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        if op==1 then
			e1:SetValue(lv)
        elseif op==2 then
        	e1:SetValue(-lv)
        end    
		tc:RegisterEffect(e1)    
	end
end