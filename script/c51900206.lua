--生命之海
function c51900206.initial_effect(c)
	c:EnableCounterPermit(0x1515) 
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN) 
	c:RegisterEffect(e1)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetOperation(c51900206.ctop)
	c:RegisterEffect(e1) 
	--token
	local e2=Effect.CreateEffect(c)  
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(3,51900206) 
	e2:SetTarget(c51900206.xxtg)
	e2:SetOperation(c51900206.xxop)
	c:RegisterEffect(e2) 
	--  
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetRange(LOCATION_FZONE) 
	e3:SetTarget(c51900206.reptg)
	e3:SetValue(c51900206.repval)
	c:RegisterEffect(e3)
end
function c51900206.cfilter(c,tp)
	return c:IsCode(51900202)
end
function c51900206.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c51900206.cfilter,1,nil,1-tp) then
		e:GetHandler():AddCounter(0x1515,1)
	end
end 
function c51900206.mnfil(c) 
	return c:IsType(TYPE_MONSTER) and Duel.IsPlayerCanSpecialSummonMonster(tp,51900202,nil,TYPES_TOKEN_MONSTER,2000,2000,8,c:GetRace(),c:GetAttribute())
end 
function c51900206.tdfil(c) 
	return c:IsFaceup() and c:IsAbleToDeck() and c:IsType(TYPE_RITUAL) 
end 
function c51900206.xxtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c51900206.mnfil,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) and e:GetHandler():IsCanRemoveCounter(tp,0x1515,2,REASON_COST) 
	local b2=Duel.IsExistingMatchingCard(c51900206.tdfil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) and e:GetHandler():IsCanRemoveCounter(tp,0x1515,3,REASON_COST) 
	if chk==0 then return b1 or b2 end 
	local lvt={}
	if b1 then table.insert(lvt,2) end 
	if b2 then table.insert(lvt,3) end 
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(51900206,2))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt)) 
	e:GetHandler():RemoveCounter(tp,0x1515,lv,REASON_COST) 
	e:SetCategory(0) 
	e:SetLabel(0)
	if lv==2 then  
		e:SetLabel(1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0) 
	end 
	if lv==3 then 
		e:SetLabel(2)
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_RECOVER)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1) 
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000) 
	end 
end
function c51900206.xxop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local x=e:GetLabel() 
	if x==1 then 
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsExistingMatchingCard(c51900206.mnfil,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) then return end 
		local tc=Duel.SelectMatchingCard(tp,c51900206.mnfil,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil):GetFirst()
		local token=Duel.CreateToken(tp,51900202)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then 
			local e1=Effect.CreateEffect(c) 
			e1:SetType(EFFECT_TYPE_SINGLE) 
			e1:SetCode(EFFECT_CHANGE_RACE) 
			e1:SetRange(LOCATION_MZONE) 
			e1:SetValue(tc:GetRace()) 
			e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
			token:RegisterEffect(e1)
			local e1=Effect.CreateEffect(c) 
			e1:SetType(EFFECT_TYPE_SINGLE) 
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE) 
			e1:SetRange(LOCATION_MZONE) 
			e1:SetValue(tc:GetAttribute()) 
			e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
			token:RegisterEffect(e1)
			local e1=Effect.CreateEffect(c) 
			e1:SetType(EFFECT_TYPE_SINGLE) 
			e1:SetCode(EFFECT_NONTUNER) 
			e1:SetRange(LOCATION_MZONE) 
			e1:SetValue(function(e,c)
			return e:GetHandler():IsControler(c:GetControler()) end) 
			e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
			token:RegisterEffect(e1)
		end 
		Duel.SpecialSummonComplete() 
	end 
	if x==2 then  
		local tc=Duel.SelectMatchingCard(tp,c51900206.tdfil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst() 
		if tc and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then  
			Duel.Recover(tp,2000,REASON_EFFECT) 
			Duel.Draw(tp,1,REASON_EFFECT) 
		end 
	end 
end
function c51900206.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsCode(79011430) 
end
function c51900206.reptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local c=e:GetHandler()
	if chk==0 then return bit.band(r,REASON_EFFECT)~=0 and re and eg:IsContains(c) and Duel.IsCanRemoveCounter(tp,1,0,0x1515,2,REASON_EFFECT) end
	if Duel.SelectEffectYesNo(tp,c,aux.Stringid(51900206,0)) then  
		Duel.RemoveCounter(tp,1,0,0x1515,2,REASON_EFFECT)
		return true
	else return false end
end
function c51900206.repval(e,c)
	return true 
end



