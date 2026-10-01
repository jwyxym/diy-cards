--圣浊的歌颂·圣徒
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--双召限制
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_CANNOT_SUMMON)
    c:RegisterEffect(e1)
	--选择效果发动
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eftg)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
	--卡组检索    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*1000)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--加入额外    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,44821013)
	e4:SetTarget(s.txtg)
	e4:SetOperation(s.txop)
	c:RegisterEffect(e4)        
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x6ce1)
end
function s.penfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.sumfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsSummonable(true,nil)
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
	if chk==0 then return (b1 or b2) end
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,3),1},
		{b2,aux.Stringid(id,4),2})
	e:SetLabel(op)	
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
		end
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY+CATEGORY_SUMMON)
		end
        Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
	end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local op=e:GetLabel()
	if c:IsRelateToEffect(e) then
    	Duel.Destroy(c,REASON_EFFECT)
  	end
    if op==1 then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local pc=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if pc then
			Duel.MoveToField(pc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
		if sc then
			Duel.Summon(tp,sc,true,nil)
		end
	end
end
function s.thfilter(c)
	return c:IsSetCard(0x6ce1) and not c:IsCode(id) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.txfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsType(TYPE_PENDULUM) and not c:IsCode(id)
    	and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.txtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.txfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.txfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,5))
	local g=Duel.SelectTarget(tp,s.txfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
end
function s.txop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoExtraP(tc,nil,REASON_EFFECT)
	end
end