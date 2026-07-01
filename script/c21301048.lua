--ISM 警戒
function c21301048.initial_effect(c)
	--Activate 
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetCountLimit(1,21301048+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c21301048.cpcost)
	e1:SetTarget(c21301048.cptg)
	e1:SetOperation(c21301048.cpop)
	c:RegisterEffect(e1)	
	--rme
	local e2=Effect.CreateEffect(c)  
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE) 
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,21300449) 
	e2:SetTarget(c21301048.rmetg)
	e2:SetOperation(c21301048.rmeop)
	c:RegisterEffect(e2) 
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21301048,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(function(e) 
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),21301048)~=0 end)
	c:RegisterEffect(e2)
	if not c21301048.global_check then
		c21301048.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_REMOVE)
		ge1:SetOperation(c21301048.checkop)
		Duel.RegisterEffect(ge1,0) 
	end
end
function c21301048.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		Duel.RegisterFlagEffect(tc:GetControler(),21301048,RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
function c21301048.ctfil(c) 
	return c:IsSetCard(0x682) and c:IsAbleToDeckAsCost()  
end 
function c21301048.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301048.ctfil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end 
	local g=Duel.SelectMatchingCard(tp,c21301048.ctfil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil) 
	Duel.SendtoDeck(g,nil,2,REASON_COST) 
end
function c21301048.cpfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x682) and c:IsAbleToRemove()
		and c:CheckActivateEffect(true,true,false)~=nil
end
function c21301048.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(c21301048.cpfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)  
end
function c21301048.cpop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,c21301048.cpfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst() 
	if tc==nil then return end 
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(true,true,true)
	Duel.Remove(tc,POS_FACEUP,REASON_COST) 
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end  
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end 
end 
function c21301048.rmetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function c21301048.rmeop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local dg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil) 
	if dg:GetCount()>0 then 
		Duel.Destroy(dg,REASON_EFFECT) 
	end 
end 


