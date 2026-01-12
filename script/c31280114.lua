--银冰龙人·菲琳
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280116)
	c:SetSPSummonOnce(id)
	--同调召唤
	s.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	--攻击力下降    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--盖放
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--破坏    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id+o*10000)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-1000)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.setfilter(c)
	return c:IsCode(31280116) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc and Duel.SSet(tp,tc)~=0 and tc:IsType(TYPE_QUICKPLAY) then
    	local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.actcon)
		tc:RegisterEffect(e1)
    end
end
function s.cfilter(c)
	return c:IsFaceup() and c:GetAttack()<c:GetTextAttack()
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(31280116)
    	and Duel.GetTurnPlayer()~=tp
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAttackPos() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsAttackPos,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
--同调召唤
function s.AddSynchroProcedure(c,f1,f2,minc,maxc)
	if maxc==nil then maxc=99 end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1164)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.SynCondition(f1,f2,minc,maxc))
	e1:SetTarget(s.SynTarget(f1,f2,minc,maxc))
	e1:SetOperation(aux.SynOperation(f1,f2,minc,maxc))
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e1)
end
function s.SynCondition(f1,f2,minc,maxc)
	return  function(e,c,smat,mg,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
				e1:SetTargetRange(0,LOCATION_MZONE)
				e1:SetRange(LOCATION_EXTRA)
				c:RegisterEffect(e1)
				local check=false
				if smat and smat:IsType(TYPE_TUNER) and (not f1 or f1(smat)) then
					if Duel.CheckTunerMaterial(c,smat,f1,f2,minc,maxc,mg) then check=true end 					
                    e :Reset()
					return check
				end
				if Duel.CheckSynchroMaterial(c,f1,f2,minc,maxc,smat,mg) then check=true end
				e1:Reset()
				return check
			end
end
function s.SynTarget(f1,f2,minc,maxc)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local g=nil
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
				e1:SetTargetRange(0,LOCATION_MZONE)
				e1:SetRange(LOCATION_EXTRA)
				c:RegisterEffect(e1)
				if smat and smat:IsType(TYPE_TUNER) and (not f1 or f1(smat)) then
					g=Duel.SelectTunerMaterial(c:GetControler(),c,smat,f1,f2,minc,maxc,mg)
				else
					g=Duel.SelectSynchroMaterial(c:GetControler(),c,f1,f2,minc,maxc,smat,mg)
				end
				e1:Reset()
				if g then
					g:KeepAlive()
					e:SetLabelObject(g)
					return true
				else return false end
			end
end