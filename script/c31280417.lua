--Happy作战会议！
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280416)
	--发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--加入手卡    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--适用效果    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o*10000)
    e2:SetCondition(s.efcon)
	e2:SetTarget(s.eftg)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end
function s.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,c:GetOriginalAttribute())
end
function s.thfilter(c,atr)
	return c:GetOriginalAttribute()~=atr and aux.IsCodeListed(c,31280416) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
    	and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) 
    	and Duel.GetFlagEffect(tp,id)==0 end
    Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tc:GetOriginalAttribute())
		if g:GetCount()>0 then
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
    end
end
function s.confilter(c,tp)
	return aux.IsCodeListed(c,31280416) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.confilter,1,nil,tp) 
end
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
function s.tufilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER)
end    
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.tufilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if chk==0 then return (b1 or b2) and Duel.GetFlagEffect(tp,id)==0 end
    Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.tufilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    if not b1 and not b2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
    local tc1=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
    if tc1 then
    	Duel.HintSelection(Group.FromCards(tc1))
        local op=aux.SelectFromOptions(tp,
			{tc1:IsLevelAbove(1),aux.Stringid(id,4),1},
			{tc1:IsLevelAbove(2),aux.Stringid(id,5),2})
        local t={}
        for i=1,3 do
			if op==2 then
            	if tc1:GetLevel()-i>0 then
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
		tc1:RegisterEffect(e1)
    end    
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))    
    local tc2=Duel.SelectMatchingCard(tp,s.tufilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
    if tc2 then
    	Duel.HintSelection(Group.FromCards(tc2))        
        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(id,6))
        e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_TUNER)
		e2:SetValue(s.tnval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e2)	
    end
end
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end