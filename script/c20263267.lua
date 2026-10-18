-- 王家魔族·前卫摇滚乐手 (ID: 20263267)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：这张卡把5星以上怪兽解放来进行上级召唤的场合，以对方场上1张魔法·陷阱卡为对象才能发动。
	-- 那张卡破坏。那之后，可以再把对方场上的，一张里侧表示的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)

	-- 注册素材检查：记录解放的素材是否包含5星以上怪兽
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)

	-- ②：只要上级召唤的这张卡在场上表侧表示存在，自己场上的「王家魔族」卡的效果以及那个发动不会被无效。
	-- 2.1 场上永续效果不会被无效
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetCondition(s.protcon)
	e2:SetTarget(s.prottg)
	c:RegisterEffect(e2)

	-- 2.2 发动不会被无效
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.protcon)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)

	-- 2.3 效果处理时不会被无效
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISEFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.protcon)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
end

-- ==================== 效果 ① 相关处理 ====================
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLevelAbove,1,nil,5) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	-- 校验为上级召唤，且解放素材中包含5星以上怪兽
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
		and (e:GetLabel()==1 or (mg and mg:IsExists(Card.IsLevelAbove,1,nil,5)))
end

function s.tgfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 严格使用原生标准的 SetOperationInfo
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 那之后，可以再把对方场上的，一张里侧表示的卡破坏
		local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end

-- ==================== 效果 ② 相关处理 ====================
function s.protcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end

function s.prottg(e,c)
	return c:IsSetCard(0x321)
end

function s.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	-- 自己场上的「王家魔族」卡发动的效果
	return tp==p and (loc&LOCATION_ONFIELD~=0) and te:GetHandler():IsSetCard(0x321)
end