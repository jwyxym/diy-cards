--奥利哈刚天神荡
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x1)
	
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	
	aux.AddCodeList(c,48179391)
	
	--①效果：自己场上有记述「山铜结界」的怪兽战斗破坏对方怪兽时，放置1个魔力指示物
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	
	--②效果：自己场上有「山铜结界」的场合，取除10个魔力指示物，对方全部卡里侧除外
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	
	--③效果：自己场上有「奥利哈刚之神」的场合，不受对方卡的效果影响
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(s.imcon)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end

s.mentioned_counter={
	[0x1]=true,
}

-- ①效果条件
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc and tc:IsPreviousControler(1-tp) and tc:IsPreviousLocation(LOCATION_MZONE)
		and (Duel.GetAttacker():IsControler(tp) and aux.IsCodeListed(Duel.GetAttacker(),48179391)
			or Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp) and aux.IsCodeListed(Duel.GetAttackTarget(),48179391))
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end

-- ②效果cost
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,10,REASON_COST)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,48179391) end
	e:GetHandler():RemoveCounter(tp,0x1,10,REASON_COST)
end

-- ②效果目标
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,0xff)
end

-- ②效果处理
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,0)
	local eg2=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
	g:Merge(eg2)
	if #g>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end

-- ③效果
function s.imcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,45205530)
end

function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

return s
