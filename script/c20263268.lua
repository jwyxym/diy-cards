-- 王家魔族·重金属歌手 (ID: 20263268)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：这张卡把5星以上怪兽解放来进行上级召唤的场合，以对方场上1只怪兽为对象才能发动。
	-- 那只怪兽破坏，这张卡的攻击力上升那只怪兽的原本等级×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
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

	-- ②：只要上级召唤的这张卡在场上表侧表示存在，自己场上的「王家魔族」怪兽不会被战斗破坏，不会被对方的效果破坏。
	-- 2.1 不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.protcon)
	e2:SetTarget(s.prottg)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- 2.2 不会被对方的效果破坏
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
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

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 严格使用原生标准的 SetOperationInfo
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local lv=tc:GetOriginalLevel()
		-- 若被破坏怪兽拥有原本等级，且自身在场表侧表示存在，则提升相应攻击力
		if lv>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(lv*200)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
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