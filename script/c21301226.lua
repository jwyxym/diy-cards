--诲王的代行
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
	--从手卡发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
    if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_LEAVE_DECK)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
    local sg=eg:Filter(Card.IsPreviousControler,nil,1-p)
	for tc in aux.Next(sg) do
		Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	e:SetLabel(0)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(100)
	end
    if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP)
    	and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
    	Duel.SetChainLimit(s.limit(g:GetFirst()))
    end
end
function s.limit(c)
	return	function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--素材限制    	
    	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTargetRange(0xff,0xff)
		e1:SetTarget(s.mttg)
        e1:SetLabelObject(tc)
		e1:SetValue(s.fuslimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e2:SetValue(1)
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		Duel.RegisterEffect(e3,tp)
		local e4=e2:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		Duel.RegisterEffect(e4,tp)
		--解放限制        
        local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetCode(EFFECT_UNRELEASABLE_SUM)
        e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e5:SetTargetRange(0xff,0xff)
        e5:SetTarget(s.mttg)
        e5:SetLabelObject(tc)
		e5:SetReset(RESET_PHASE+PHASE_END)
		e5:SetValue(1)
		Duel.RegisterEffect(e5,tp)
		--发动限制        
        local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_CANNOT_TRIGGER)
        e6:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e6:SetTargetRange(0xff,0xff)
        e6:SetTarget(s.mttg)
        e6:SetLabelObject(tc)
		e6:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e6,tp)
		--离场重定        
        local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e7:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e7:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
        e7:SetTarget(s.mttg)
        e7:SetLabelObject(tc)
        e7:SetValue(LOCATION_DECK)
		e7:SetReset(RESET_PHASE+PHASE_END)		
		Duel.RegisterEffect(e7,tp)
    end
    if e:GetLabel()==100 then
		--加手自肃
    	local e8=Effect.CreateEffect(c)
		e8:SetDescription(aux.Stringid(id,2))
		e8:SetType(EFFECT_TYPE_FIELD)
		e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e8:SetCode(EFFECT_CANNOT_TO_HAND)
		e8:SetTargetRange(1,0)
		Duel.RegisterEffect(e8,tp)
        local e9=Effect.CreateEffect(c)
		e9:SetType(EFFECT_TYPE_FIELD)
		e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e9:SetCode(EFFECT_CANNOT_DRAW)
		e9:SetTargetRange(1,0)
		Duel.RegisterEffect(e9,tp)
    end
end
function s.mttg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
function s.handcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end