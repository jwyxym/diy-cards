--绝命的痛击
local s,id,o=GetID()
function s.initial_effect(c)
	--无效
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--改变效果    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.chcon)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
    if not s.global_flag then
		s.global_flag=true
		s[0]={}
		s[1]={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)	
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)	
	for tc in aux.Next(eg) do
    	if not tc:IsSetCard(0xaca1) then return end
		local code=tc:GetCode()
		if Duel.GetFlagEffect(tc:GetSummonPlayer(),id)>0 then return end
		e:SetLabel(0)
		for _,fcode in ipairs(s[tc:GetSummonPlayer()]) do
			if fcode==code then
				e:SetLabel(100)
			end
		end
		if e:GetLabel()==0 then table.insert(s[tc:GetSummonPlayer()],code) end
		if #s[tc:GetSummonPlayer()]>=9 then 
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,0,0,0)
		end
	end
end
function s.confilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
    	and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,2,nil)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkfilter(c)
	return c:IsFaceup() and not c:IsAttack(0)
end    
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		and Duel.Destroy(eg,REASON_EFFECT)~=0 then
        local sg=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
        if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        	Duel.BreakEffect()
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local sc=sg:Select(tp,1,1,nil)
            if not sc then return end
            Duel.HintSelection(Group.FromCards(sc))
            local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
        end
	end
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==tp and (loc&LOCATION_ONFIELD)~=0 and re:IsActiveType(TYPE_MONSTER) 
    	and Duel.GetFlagEffect(tp,id)>0
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.damcon)
	e1:SetOperation(s.damop)
    if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_STANDBY then    
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,2)
        e1:SetLabel(Duel.GetTurnCount())
    else
    	e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN)
        e1:SetLabel(0)
    end    
	Duel.RegisterEffect(e1,tp)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.GetTurnCount()~=e:GetLabel() 
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-tp,8000,REASON_EFFECT)
end