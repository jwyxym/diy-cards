--瘟疫罗刹
local s,id=GetID()
function s.initial_effect(c)
	--通常发动
	local eact=Effect.CreateEffect(c)
	eact:SetType(EFFECT_TYPE_ACTIVATE)
	eact:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(eact)
	
	--这张卡也能把自己场上的1只怪兽解放，在盖放的回合发动
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,2))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCost(s.setcost)
	c:RegisterEffect(e0)
	
	--①效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-1000)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.szcon)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	
	--②效果
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

function s.szcon(e)
	return e:GetHandler():IsLocation(LOCATION_SZONE)
end

function s.relfilter(c)
	if c:IsReleasable() then
		if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_TOFIELD,0x7f)<=0 then
			return c:GetSequence()<5
		end
		return true
	end
	return false
end

function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Release(g,REASON_COST)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabel(g:GetFirst():IsAttribute(ATTRIBUTE_DARK) and 1 or 0)
	Duel.Release(g,REASON_COST)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if ct>0 then
		Duel.Damage(1-tp,ct*200,REASON_EFFECT)
	end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,nil)
		and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	
	c:AddMonsterAttribute(TYPE_EFFECT)
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(RACE_ZOMBIE)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(ATTRIBUTE_DARK)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_LEVEL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(8)
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
	
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_BASE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(1500)
	e4:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e4)
	
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SET_BASE_DEFENSE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(1000)
	e5:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e5)
	
	if Duel.SpecialSummonStep(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP) then
		if c:GetFlagEffect(id+1000)==0 then
			c:RegisterFlagEffect(id+1000,0,0,1)
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_FIELD)
			e6:SetCode(EFFECT_UPDATE_ATTACK)
			e6:SetRange(LOCATION_MZONE)
			e6:SetTargetRange(0,LOCATION_MZONE)
			e6:SetValue(-1000)
			c:RegisterEffect(e6)
		end
		
		local e7=Effect.CreateEffect(c)
		e7:SetDescription(aux.Stringid(id,3))
		e7:SetType(EFFECT_TYPE_QUICK_O)
		e7:SetCode(EVENT_FREE_CHAIN)
		e7:SetRange(LOCATION_MZONE)
		e7:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
		e7:SetCondition(s.setcon)
		e7:SetTarget(s.settg)
		e7:SetOperation(s.setop)
		c:RegisterEffect(e7)
	end
	Duel.SpecialSummonComplete()
	
	if e:GetLabel()==1 then
		local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		if ct>0 then
			Duel.Damage(1-tp,ct*300,REASON_EFFECT)
		end
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():IsCanBePlacedOnField() end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

return s
