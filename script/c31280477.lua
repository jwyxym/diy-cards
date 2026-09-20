--死骸突袭者
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102)
	--融合召唤
	aux.AddFusionProcFun2(c,s.matfilter,aux.FilterBoolFunction(Card.IsFusionType,TYPE_EFFECT),true)	
	s.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
    c:EnableReviveLimit()
	--破坏    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.flagop)
	c:RegisterEffect(e2)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--攻守上升    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atktg)
	e3:SetValue(800)
	c:RegisterEffect(e3)
    local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	--给与伤害    
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.damcon)
    e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
    if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.matfilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsType(TYPE_FUSION)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
    	local p=tc:GetSummonPlayer()
    	if tc:IsSummonType(SUMMON_TYPE_FUSION) and tc:IsType(TYPE_FUSION) and tc:IsRace(RACE_ZOMBIE) then
			Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and e:GetHandler():GetFlagEffect(id)>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.atktg(e,c)
	return c:IsRace(RACE_ZOMBIE)
end
function s.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsAttack(0)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end	
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Damage(1-tp,500,REASON_EFFECT)~=0 then
    	local res=false
    	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
        if g:GetCount()>0 then
        	for tc in aux.Next(g) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e1:SetRange(LOCATION_MZONE)
				e1:SetValue(-1000)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
                res=true
            end
            if res then
            	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
                if dg:GetCount()>0 then
                	Duel.BreakEffect()
                	Duel.Destroy(dg,REASON_EFFECT)
                end
            end
    	end
    end
end
function s.AddContactFusionProcedure(c,filter,self_location,opponent_location,mat_operation,...)
	self_location=self_location or 0
	opponent_location=opponent_location or 0
	local operation_params={...}
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.ContactFusionCondition(filter,self_location,opponent_location))
	e2:SetTarget(aux.ContactFusionTarget(filter,self_location,opponent_location))
	e2:SetOperation(aux.ContactFusionOperation(mat_operation,operation_params))
	c:RegisterEffect(e2)
	return e2
end
function s.ContactFusionCondition(filter,self_location,opponent_location)
	return	function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=Duel.GetMatchingGroup(aux.ContactFusionMaterialFilter,tp,self_location,opponent_location,c,c,filter)
				return c:CheckFusionMaterial(mg,nil,tp|0x200) and Duel.GetFlagEffect(tp,id)>0
			end
end